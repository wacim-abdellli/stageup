# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_approved_coordinator!
  before_action :ensure_student!, only: [:update_cv]

  def show
    @user = current_user
    @role_type = @user.profileable_type
    @profile = @user.profileable

    if @role_type == "StudentProfile"
      submissions = @profile.submissions.where(status: ["accepted", "completed"])
      @active_internships = submissions.includes({ offer: :company_profile }, :reviews, :internship_agreement).order(created_at: :desc)
      @completed_internships_count = @profile.submissions.where(status: "completed").count
      @commitment_ledger_events = @profile.commitment_events.order(created_at: :desc).limit(50)
    elsif @role_type == "CompanyProfile"
      company_subs = @profile.submissions.where(status: ["accepted", "completed"])
      @active_internships = company_subs.includes(:student_profile, :offer, :reviews, :internship_agreement).order(created_at: :desc)
      @completed_internships_count = @profile.submissions.where(status: "completed").count
      @offers_count = @profile.offers.count

      offer_ids = @profile.offers.select(:id)
      pending = Submission.where(offer_id: offer_ids).where(status: "submitted")
      @pending_submissions = pending.includes(:offer, student_profile: { cv_attachment: :blob }).order(created_at: :desc)

      processed = Submission.where(offer_id: offer_ids).where(status: ["accepted", "rejected", "completed"])
      @processed_submissions = processed.includes(:student_profile, :offer).order(responded_at: :desc).limit(10)

      @company_offers = @profile.offers.includes(:skills).order(created_at: :desc)

      @commitment_ledger_events = @profile.commitment_events.order(created_at: :desc).limit(50)
    elsif @role_type == "UniversityProfile"
      @university = @profile.university
      per_page = 50
      @student_page = [(params[:student_page] || 1).to_i, 1].max
      @students_total = StudentProfile.where(university: @university).count
      @total_students_count = @students_total
      @student_total_pages = (@students_total.to_f / per_page).ceil
      @students = StudentProfile.where(university: @university)
                    .includes(:user, submissions: :internship_agreement)
                    .order(last_name: :asc)
                    .limit(per_page)
                    .offset((@student_page - 1) * per_page)
      @active_internships_count = Submission.joins(:student_profile)
                                             .where(student_profiles: { university_id: @university.id })
                                             .where(status: ["accepted", "completed"])
                                             .count
      @avg_student_score = StudentProfile.where(university: @university).average(:commitment_score)&.round(1) || 100.0
      @recent_reputation_events = CommitmentEvent
                                   .where(profileable_type: "StudentProfile",
                                          profileable_id: StudentProfile.where(university_id: @university.id).select(:id))
                                   .includes(:profileable)
                                   .order(created_at: :desc)
                                   .limit(20)
    end
  end

  def update_cv
    @profile = current_user.profileable

    if params[:student_profile].blank? || params[:student_profile][:cv].blank?
      redirect_to dashboard_path, alert: "Please select a PDF file before clicking Upload."
      return
    end

    if @profile.update(cv_params)
      redirect_to dashboard_path, notice: "CV successfully uploaded!"
    else
      redirect_to dashboard_path, alert: "Failed to upload CV: #{@profile.errors.full_messages.join(', ')}"
    end
  end

  private

  def cv_params
    params.require(:student_profile).permit(:cv)
  end

  def ensure_student!
    return if current_user.profileable_type == "StudentProfile"

    redirect_to dashboard_path, alert: "Only students can upload CVs."
  end

  def ensure_approved_coordinator!
    if current_user.profileable_type == "UniversityProfile" && !current_user.profileable.approved?
      @user = current_user
      @profile = current_user.profileable
      render "dashboards/pending_approval"
    end
  end
end
