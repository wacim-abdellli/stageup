module Admin
  class CompanyProfilesController < AdminController
    before_action :set_profile, only: [:verify, :unverify]

    def index
      @profiles = CompanyProfile.includes(:user).order(created_at: :desc)

      if params[:status] == "unverified"
        @profiles = @profiles.where(verified: false)
      elsif params[:status] == "verified"
        @profiles = @profiles.where(verified: true)
      end

      if params[:query].present?
        q = "%#{params[:query].downcase}%"
        @profiles = @profiles.where("LOWER(name) LIKE ? OR LOWER(website) LIKE ?", q, q)
      end

      @profiles = @profiles.limit(100)
    end

    def verify
      @profile.update!(verified: true)
      Notification.trigger(
        recipient: @profile.user,
        action: "company_verified",
        message: "Your company account has been verified. You can now post internship offers.",
        notifiable: @profile
      )
      UserMailer.company_verified_email(@profile.user, @profile).deliver_later rescue nil
      redirect_back fallback_location: admin_company_profiles_path, notice: "#{@profile.name} has been verified."
    end

    def unverify
      @profile.update!(verified: false)
      Notification.trigger(
        recipient: @profile.user,
        action: "company_unverified",
        message: "Your company account verification has been revoked by StageUp administrators.",
        notifiable: @profile
      )
      redirect_back fallback_location: admin_company_profiles_path, notice: "#{@profile.name} has been unverified."
    end

    private

    def set_profile
      @profile = CompanyProfile.find(params[:id])
    end
  end
end
