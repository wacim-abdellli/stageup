# frozen_string_literal: true

class CertificatesController < ApplicationController
  layout 'certificate'
  skip_before_action :authenticate_user!
  skip_before_action :ensure_valid_profile!

  def verify
    token = params[:token] || params[:id]
    if token.blank?
      redirect_to root_path, alert: "Please provide a valid certificate verification token or scan a certificate QR code."
      return
    end

    @agreement = InternshipAgreement.find_by(verification_token: token)
    if @agreement.nil?
      redirect_to root_path, alert: "The requested resource was not found."
      return
    end

    unless @agreement.status == "fully_executed"
      redirect_to root_path, alert: "This certificate has not been fully executed yet."
      return
    end

    @submission = @agreement.submission
    @student    = @submission.student_profile
    @offer      = @submission.offer
    @company    = @offer.company_profile
  end
end
