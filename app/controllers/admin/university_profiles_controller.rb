module Admin
  class UniversityProfilesController < AdminController
    before_action :set_profile

    def approve
      @profile.update!(approved: true)
      Notification.trigger(
        recipient: @profile.user,
        action: "coordinator_approved",
        message: "Your university coordinator account has been approved. You can now manage internship agreements.",
        notifiable: @profile
      )
      UserMailer.coordinator_approved_email(@profile.user, @profile).deliver_later
      redirect_to admin_dashboard_path, notice: "#{@profile.admin_name} has been approved."
    end

    def reject
      @profile.user&.destroy
      @profile.destroy
      redirect_to admin_dashboard_path, notice: "Coordinator profile has been rejected and removed."
    end

    private

    def set_profile
      @profile = UniversityProfile.find(params[:id])
    end
  end
end
