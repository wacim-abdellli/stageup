module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :toggle_admin, :toggle_lock]

    def index
      @users = User.includes(:profileable).order(created_at: :desc)

      if params[:query].present?
        q = "%#{params[:query].downcase}%"
        @users = @users.where("LOWER(email) LIKE ?", q)
      end

      if params[:role].present?
        case params[:role]
        when "student"
          @users = @users.where(profileable_type: "StudentProfile")
        when "company"
          @users = @users.where(profileable_type: "CompanyProfile")
        when "university"
          @users = @users.where(profileable_type: "UniversityProfile")
        when "admin"
          @users = @users.where(admin: true)
        end
      end

      @users = @users.limit(100)
    end

    def show
    end

    def toggle_admin
      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot change your own admin status."
        return
      end

      new_admin_state = !@user.admin
      User.where(id: @user.id).update_all(admin: new_admin_state)
      @user.reload
      new_status = @user.admin? ? "granted admin privileges" : "removed admin privileges"
      redirect_to admin_users_path, notice: "User #{@user.email} #{new_status}."
    end

    def toggle_lock
      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot lock your own account."
        return
      end

      if @user.access_locked?
        @user.unlock_access!
        msg = "unlocked"
      else
        @user.lock_access!
        msg = "locked"
      end

      redirect_to admin_users_path, notice: "User #{@user.email} account has been #{msg}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
