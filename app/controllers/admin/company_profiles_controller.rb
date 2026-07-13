module Admin
  class CompanyProfilesController < AdminController
    before_action :set_profile

    def verify
      @profile.update!(verified: true)
      Notification.trigger(
        recipient: @profile.user,
        action: "company_verified",
        message: "Your company account has been verified. You can now post internship offers.",
        notifiable: @profile
      )
      UserMailer.company_verified_email(@profile.user, @profile).deliver_later
      redirect_to admin_dashboard_path, notice: "#{@profile.name} has been verified."
    end

    def unverify
      @profile.update!(verified: false)
      Notification.trigger(
        recipient: @profile.user,
        action: "company_verified",
        message: "Your company account verification has been revoked by StageUp administrators. Please contact support.",
        notifiable: @profile
      )
      redirect_to admin_dashboard_path, notice: "#{@profile.name} has been unverified."
    end

    private

    def set_profile
      @profile = CompanyProfile.find(params[:id])
    end
  end
end
