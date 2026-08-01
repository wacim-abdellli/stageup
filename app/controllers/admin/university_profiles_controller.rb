module Admin
  class UniversityProfilesController < AdminController
    before_action :set_profile, only: [:approve, :unapprove, :reject]

    def index
      @profiles = UniversityProfile.includes(:university, :user).order(created_at: :desc)

      if params[:status] == "pending"
        @profiles = @profiles.where(approved: false)
      elsif params[:status] == "approved"
        @profiles = @profiles.where(approved: true)
      end

      if params[:query].present?
        q = "%#{params[:query].downcase}%"
        @profiles = @profiles.where("LOWER(admin_name) LIKE ? OR LOWER(department) LIKE ?", q, q)
      end

      @profiles = @profiles.limit(100)
    end

    def approve
      @profile.update!(approved: true)
      Notification.trigger(
        recipient: @profile.user,
        action: "coordinator_approved",
        message: "Your university coordinator account has been approved. You can now manage internship agreements.",
        notifiable: @profile
      )
      begin
        UserMailer.coordinator_approved_email(@profile.user, @profile).deliver_later
      rescue StandardError => e
        Rails.logger.error("[Mailer] coordinator_approved_email failed: #{e.message}")
      end
      redirect_back fallback_location: admin_dashboard_path, notice: "#{@profile.admin_name} has been approved."
    end

    def unapprove
      @profile.update!(approved: false)
      Notification.trigger(
        recipient: @profile.user,
        action: "coordinator_approved",
        message: "Your university coordinator approval has been revoked by StageUp administrators.",
        notifiable: @profile
      )
      redirect_back fallback_location: admin_dashboard_path, notice: "Approval for #{@profile.admin_name} has been revoked."
    end

    def reject
      ActiveRecord::Base.transaction do
        @profile.user&.destroy!
        @profile.destroy!
      end
      redirect_back fallback_location: admin_dashboard_path, notice: "Coordinator profile has been rejected and removed."
    rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid
      redirect_back fallback_location: admin_dashboard_path, alert: "Failed to reject coordinator. Please try again."
    end

    private

    def set_profile
      @profile = UniversityProfile.find(params[:id])
    end
  end
end
