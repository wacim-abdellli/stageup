# frozen_string_literal: true

class CertificatesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_valid_profile!

  def verify
    @agreement = InternshipAgreement.find_by!(verification_token: params[:token])
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
