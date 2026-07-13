# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def application_received_email(user, submission)
    @user = user
    @submission = submission
    @offer = submission.offer
    @company = submission.offer.company_profile
    mail(to: @company.user.email, subject: "New Application Received – #{@offer.title}")
  end

  def application_status_updated_email(user, submission)
    @user = user
    @submission = submission
    @offer = submission.offer
    @company = submission.offer.company_profile
    @status = submission.status
    mail(to: @user.email, subject: "Application #{@status.humanize} – #{@offer.title}")
  end

  def agreement_signature_requested_email(user, agreement)
    @user = user
    @agreement = agreement
    @submission = agreement.submission
    @offer = @submission.offer
    mail(to: @user.email, subject: "Convention de Stage Ready for Signature – #{@offer.title}")
  end

  def agreement_declined_email(user, agreement)
    @user = user
    @agreement = agreement
    @submission = agreement.submission
    @offer = @submission.offer
    @reason = agreement.rejection_reason
    mail(to: @user.email, subject: "Convention de Stage Declined – #{@offer.title}")
  end

  def coordinator_approved_email(user, profile)
    @user = user
    @profile = profile
    mail(to: @user.email, subject: "Your Coordinator Account Has Been Approved")
  end

  def company_verified_email(user, profile)
    @user = user
    @profile = profile
    mail(to: @user.email, subject: "Your Company Account Has Been Verified")
  end
end
