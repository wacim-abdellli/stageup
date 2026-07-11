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
      @active_internships = submissions.includes({ offer: :company_profile }, :reviews).order(created_at: :desc)
      @completed_internships_count = @profile.submissions.where(status: "completed").count
      @commitment_ledger_events = @profile.commitment_events.order(created_at: :desc)
    elsif @role_type == "CompanyProfile"
      company_subs = @profile.submissions.where(status: ["accepted", "completed"])
      @active_internships = company_subs.includes(:student_profile, :offer, :reviews).order(created_at: :desc)
      @completed_internships_count = @profile.submissions.where(status: "completed").count
      @offers_count = @profile.offers.count

      offer_ids = @profile.offers.select(:id)
      pending = Submission.where(offer_id: offer_ids).where(status: "submitted")
      @pending_submissions = pending.includes(:offer, student_profile: { cv_attachment: :blob }).order(created_at: :desc)

      processed = Submission.where(offer_id: offer_ids).where(status: ["accepted", "rejected", "completed"])
      @processed_submissions = processed.includes(:student_profile, :offer).order(responded_at: :desc).limit(10)

      @company_offers = @profile.offers.order(created_at: :desc)

      @commitment_ledger_events = @profile.commitment_events.order(created_at: :desc)
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
    unless current_user.profileable_type == "StudentProfile"
      redirect_to dashboard_path, alert: "Only students can upload CVs."
    end
  end

  def ensure_approved_coordinator!
    if current_user.profileable_type == "UniversityProfile" && !current_user.profileable.approved?
      render "dashboards/pending_approval"
    end
  end
end
