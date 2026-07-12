class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!, only: [:create, :edit, :update]
  before_action :ensure_company!, only: [:accept, :reject]
  before_action :set_submission_for_student, only: [:edit, :update]
  before_action :set_submission_for_company, only: [:accept, :reject]
  before_action :set_submission_for_completion, only: [:confirm_completion]

  # POST /submissions
  def create
    @offer = Offer.find(params[:offer_id])

    unless @offer.status == "active"
      redirect_to offer_path(@offer), alert: "You cannot apply to an inactive offer."
      return
    end

    @mission = params[:mission_id].present? ? Mission.find(params[:mission_id]) : nil

    # Create submission
    @submission = current_user.profileable.submissions.build(
      offer: @offer,
      mission: @mission,
      status: @offer.mission.present? ? "started" : "submitted",
      submitted_at: @offer.mission.present? ? nil : Time.current
    )

    if @submission.save
      company_user = @offer.company_profile.user
      student_name = "#{current_user.profileable.first_name} #{current_user.profileable.last_name}"
      Notification.trigger(
        recipient: company_user,
        action: "application_received",
        message: "#{student_name} applied to #{@offer.title}.",
        notifiable: @submission
      )
      UserMailer.application_received_email(@submission.student_profile.user, @submission).deliver_later unless @offer.mission.present?

      notice_msg = if @offer.mission.present?
                     "Mission started! You have 48 hours to submit your solution."
                   else
                     "Application successfully submitted with your CV."
                   end
      redirect_to offer_path(@offer), notice: notice_msg
    else
      redirect_to offer_path(@offer), alert: "Unable to start application: #{@submission.errors.full_messages.join(', ')}"
    end
  end

  # GET /submissions/:id/edit
  def edit
    unless @submission.status == "started"
      redirect_to offer_path(@submission.offer), alert: "This application has already been submitted."
    end
  end

  # PATCH/PUT /submissions/:id
  def update
    unless @submission.status == "started"
      redirect_to dashboard_path, alert: "This submission cannot be updated."
      return
    end

    @submission.assign_attributes(submission_params)
    @submission.status = "under_review"
    @submission.submitted_at = Time.current

    if @submission.save
      VerifySubmissionJob.perform_later(@submission)
      redirect_to offer_path(@submission.offer), notice: "Your proof mission was successfully submitted!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /submissions/:id/accept
  def accept
    unless %w[submitted under_review].include?(@submission.status)
      redirect_to dashboard_path, alert: "This submission cannot be accepted in its current state."
      return
    end

    @submission.status = "accepted"
    @submission.responded_at = Time.current

    ActiveRecord::Base.transaction do
      if @submission.save
        log_company_response_event(@submission)
        company = @submission.offer.company_profile
        company.recalculate_metrics!
        company.recalculate_commitment_score!
        student_user = @submission.student_profile.user
        Notification.trigger(
          recipient: student_user,
          action: "application_accepted",
          message: "Your application for #{@submission.offer.title} has been accepted!",
          notifiable: @submission
        )
        UserMailer.application_status_updated_email(student_user, @submission).deliver_later
        redirect_to dashboard_path, notice: "Application was successfully accepted! We logged your response."
      else
        redirect_to dashboard_path, alert: "Failed to accept application."
      end
    end
  end

  # POST /submissions/:id/reject
  def reject
    unless %w[submitted under_review].include?(@submission.status)
      redirect_to dashboard_path, alert: "This submission cannot be rejected in its current state."
      return
    end

    @submission.status = "rejected"
    @submission.responded_at = Time.current

    ActiveRecord::Base.transaction do
      if @submission.save
        log_company_response_event(@submission)
        company = @submission.offer.company_profile
        company.recalculate_metrics!
        company.recalculate_commitment_score!
        student_user = @submission.student_profile.user
        Notification.trigger(
          recipient: student_user,
          action: "application_rejected",
          message: "Your application for #{@submission.offer.title} has been rejected.",
          notifiable: @submission
        )
        UserMailer.application_status_updated_email(student_user, @submission).deliver_later
        redirect_to dashboard_path, notice: "Application was rejected. We logged your response."
      else
        redirect_to dashboard_path, alert: "Failed to reject application."
      end
    end
  end

  # POST /submissions/:id/abandon
  def abandon
    @submission = current_user.profileable.submissions.find(params[:id])

    unless @submission.status == "accepted"
      redirect_to dashboard_path, alert: "You can only abandon an active internship."
      return
    end

    @submission.update!(status: "abandoned", responded_at: Time.current)

    student = @submission.student_profile
    student.commitment_events.create!(
      event_type: "student_abandoned_mission",
      score_delta: -25.0,
      description: "Abandoned internship '#{@submission.offer.title}' at #{@submission.offer.company_profile.name}."
    )
    student.recalculate_commitment_score!

    company_user = @submission.offer.company_profile.user
    Notification.trigger(
      recipient: company_user,
      action: "internship_abandoned",
      message: "#{@submission.student_profile.first_name} #{@submission.student_profile.last_name} has abandoned the internship for #{@submission.offer.title}.",
      notifiable: @submission
    )

    redirect_to dashboard_path, notice: "You have abandoned the internship. A penalty has been applied to your commitment score."
  end

  # POST /submissions/:id/cancel
  def cancel
    @submission = Submission.joins(:offer).where(offers: { company_profile_id: current_user.profileable_id }).find(params[:id])

    unless @submission.status == "accepted"
      redirect_to dashboard_path, alert: "You can only cancel an active internship."
      return
    end

    ActiveRecord::Base.transaction do
      @submission.update!(status: "abandoned", responded_at: Time.current)

      student = @submission.student_profile
      student.commitment_events.create!(
        event_type: "student_ghosted_offer",
        score_delta: -15.0,
        description: "Ghosted employer on active internship for '#{@submission.offer.title}'."
      )
      student.recalculate_commitment_score!
    end

    student_user = @submission.student_profile.user
    Notification.trigger(
      recipient: student_user,
      action: "internship_cancelled",
      message: "Your internship for #{@submission.offer.title} has been cancelled by the company.",
      notifiable: @submission
    )

    redirect_to dashboard_path, notice: "Internship has been cancelled and the student's commitment score has been adjusted."
  end

  # POST /submissions/:id/confirm_completion
  def confirm_completion
    if @submission.internship_agreement.nil?
      redirect_to dashboard_path, alert: "You cannot mark this internship as completed until a Convention de Stage has been generated."
      return
    end

    unless @submission.internship_agreement.status == "fully_executed"
      redirect_to dashboard_path, alert: "You cannot mark this internship as completed until the Convention de Stage is fully signed by all three parties."
      return
    end

    role = current_user.profileable_type
    @submission.confirm_completion_by!(role)

    if @submission.status == "completed"
      other_party = role == "StudentProfile" ? @submission.offer.company_profile.user : @submission.student_profile.user
      Notification.trigger(
        recipient: other_party,
        action: "internship_completed",
        message: "Internship for #{@submission.offer.title} has been marked as completed by both parties!",
        notifiable: @submission
      )
    end

    notice_msg = if @submission.status == "completed"
                   "Internship successfully completed! You can now leave a review."
                 else
                   "Your completion confirmation has been logged. Waiting for the other side to confirm."
                 end
    redirect_to dashboard_path, notice: notice_msg
  end

  private

  def set_submission_for_student
    @submission = current_user.profileable.submissions.find(params[:id])
  end

  def set_submission_for_company
    # Find the submission, ensuring the company owns the offer it belongs to
    @submission = Submission.joins(:offer).where(offers: { company_profile_id: current_user.profileable_id }).find(params[:id])
  end

  def set_submission_for_completion
    if current_user.profileable_type == "StudentProfile"
      @submission = current_user.profileable.submissions.find(params[:id])
    elsif current_user.profileable_type == "CompanyProfile"
      @submission = Submission.joins(:offer).where(offers: { company_profile_id: current_user.profileable_id }).find(params[:id])
    else
      redirect_to dashboard_path, alert: "Not authorized."
    end
  end

  def submission_params
    params.require(:submission).permit(:github_link, :submission_notes)
  end

  def ensure_student!
    unless current_user.profileable_type == "StudentProfile"
      redirect_to dashboard_path, alert: "Only students can apply or submit proof of work."
    end
  end

  def ensure_company!
    unless current_user.profileable_type == "CompanyProfile"
      redirect_to dashboard_path, alert: "Only companies can review or accept/reject applications."
    end
  end

  def log_company_response_event(submission)
    company = submission.offer.company_profile
    submitted = submission.submitted_at || submission.created_at
    late = submitted < 14.days.ago

    event_type = late ? "company_responded_late" : "company_responded_on_time"
    delta = late ? -5.0 : +1.0
    desc = late ? "Responded late (over 14 days) to application for '#{submission.offer.title}'" : "Responded on time (within 14 days) to application for '#{submission.offer.title}'"

    company.commitment_events.create!(
      event_type: event_type,
      score_delta: delta,
      description: desc
    )
  end
end
