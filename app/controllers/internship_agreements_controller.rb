# frozen_string_literal: true

class InternshipAgreementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_submission
  before_action :authorize_user!
  before_action :set_agreement, only: [:show, :sign, :decline]
  before_action :ensure_submission_accepted!, only: [:new, :create]
  before_action :ensure_signable!, only: [:sign]

  def new
    @agreement = @submission.build_internship_agreement
  end

  def create
    @agreement = @submission.build_internship_agreement(agreement_params)

    if @agreement.save
      redirect_to submission_internship_agreement_path(@submission, @agreement),
                  notice: "Convention de Stage created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def sign
    @agreement.sign_by!(current_user.profileable_type)

    unless @agreement.status == "fully_executed"
      pending_users = []
      student_user = @submission.student_profile.user
      company_user = @submission.offer.company_profile.user

      pending_users << student_user if @agreement.student_signed_at.nil? && student_user != current_user
      pending_users << company_user if @agreement.company_signed_at.nil? && company_user != current_user

      pending_users.uniq.each do |u|
        Notification.trigger(
          recipient: u,
          action: "agreement_signature_requested",
          message: "The Convention de Stage for #{@submission.offer.title} is ready for your signature.",
          notifiable: @agreement
        )
        UserMailer.agreement_signature_requested_email(u, @agreement).deliver_later
      end
    end

    redirect_to submission_internship_agreement_path(@submission, @agreement),
                notice: "Agreement signed successfully."
  end

  def decline
    unless current_user.profileable_type == "UniversityProfile"
      redirect_to dashboard_path, alert: "Only university coordinators can decline agreements."
      return
    end

    if @agreement.update(status: "declined", rejection_reason: params[:rejection_reason])
      student_user = @submission.student_profile.user
      company_user = @submission.offer.company_profile.user

      [student_user, company_user].each do |u|
        Notification.trigger(
          recipient: u,
          action: "agreement_declined",
          message: "The Convention de Stage for #{@submission.offer.title} has been declined by the university. Reason: #{@agreement.rejection_reason}",
          notifiable: @agreement
        )
        UserMailer.agreement_declined_email(u, @agreement).deliver_later
      end

      redirect_to submission_internship_agreement_path(@submission, @agreement),
                  notice: "Agreement has been declined. All parties have been notified."
    else
      flash.now[:alert] = "Failed to decline: #{@agreement.errors.full_messages.join(', ')}"
      render :show
    end
  end

  private

  def set_submission
    @submission = Submission.find(params[:submission_id])
  end

  def set_agreement
    @agreement = @submission.internship_agreement
    return if @agreement

    redirect_to dashboard_path, alert: "Agreement not found."
    throw(:abort)
  end

  def ensure_submission_accepted!
    return if @submission.status == "accepted"

    redirect_to dashboard_path, alert: "You can only generate an agreement for an accepted internship."
    throw(:abort)
  end

  def ensure_signable!
    if @agreement.status == "fully_executed"
      redirect_to submission_internship_agreement_path(@submission, @agreement),
                  alert: "This agreement is already fully executed and cannot be signed again."
      throw(:abort)
    end

    if @agreement.status == "declined"
      redirect_to submission_internship_agreement_path(@submission, @agreement),
                  alert: "This agreement has been declined and cannot be signed."
      throw(:abort)
    end

    if already_signed?
      redirect_to submission_internship_agreement_path(@submission, @agreement),
                  alert: "You have already signed this agreement."
      throw(:abort)
    end
  end

  def already_signed?
    case current_user.profileable_type
    when "StudentProfile" then @agreement.student_signed_at.present?
    when "CompanyProfile" then @agreement.company_signed_at.present?
    when "UniversityProfile" then @agreement.university_signed_at.present?
    else false
    end
  end

  def authorize_user!
    role = current_user.profileable_type
    profile = current_user.profileable

    authorized = case role
    when "StudentProfile"
      @submission.student_profile == profile
    when "CompanyProfile"
      @submission.offer.company_profile == profile
    when "UniversityProfile"
      profile.approved? && @submission.student_profile.university_id == profile.university_id
    else
      false
    end

    return if authorized

    redirect_to dashboard_path, alert: "You are not authorized to manage this agreement."
    throw(:abort)
  end

  def agreement_params
    params.require(:internship_agreement).permit(:start_date, :end_date)
  end
end
