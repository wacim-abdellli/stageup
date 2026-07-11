class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_approved_coordinator!
  before_action :ensure_student!, only: [:update_cv]

  def show
    @user = current_user
    @role_type = @user.profileable_type
    @profile = @user.profileable
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
