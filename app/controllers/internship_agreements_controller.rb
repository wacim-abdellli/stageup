class InternshipAgreementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_submission
  before_action :authorize_user!
  before_action :set_agreement, only: [:show, :sign]

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
    redirect_to submission_internship_agreement_path(@submission, @agreement),
                notice: "Agreement signed successfully."
  end

  private

  def set_submission
    @submission = Submission.find(params[:submission_id])
  end

  def set_agreement
    @agreement = @submission.internship_agreement
    redirect_to dashboard_path, alert: "Agreement not found." unless @agreement
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
      @submission.student_profile.university_id == profile.university_id
    else
      false
    end

    unless authorized
      redirect_to dashboard_path, alert: "You are not authorized to manage this agreement."
    end
  end

  def agreement_params
    params.require(:internship_agreement).permit(:start_date, :end_date)
  end
end
