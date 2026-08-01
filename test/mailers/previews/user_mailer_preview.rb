# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def application_received_email
    submission = Submission.includes(:offer).first
    user = submission&.offer&.company_profile&.user || User.first
    UserMailer.application_received_email(user, submission || Submission.first)
  end

  def application_status_updated_email
    submission = Submission.where(status: %w[accepted rejected]).first || Submission.first
    user = submission&.student_profile&.user || User.first
    UserMailer.application_status_updated_email(user, submission)
  end

  def agreement_signature_requested_email
    agreement = InternshipAgreement.first
    user = agreement&.submission&.student_profile&.user || User.first
    UserMailer.agreement_signature_requested_email(user, agreement || InternshipAgreement.first)
  end

  def agreement_declined_email
    agreement = InternshipAgreement.where(status: "declined").first || InternshipAgreement.first
    user = agreement&.submission&.student_profile&.user || User.first
    UserMailer.agreement_declined_email(user, agreement || InternshipAgreement.first)
  end

  def coordinator_approved_email
    profile = UniversityProfile.where(approved: true).first || UniversityProfile.first
    user = profile&.user || User.first
    UserMailer.coordinator_approved_email(user, profile || UniversityProfile.first)
  end

  def company_verified_email
    profile = CompanyProfile.where(verified: true).first || CompanyProfile.first
    user = profile&.user || User.first
    UserMailer.company_verified_email(user, profile || CompanyProfile.first)
  end
end
