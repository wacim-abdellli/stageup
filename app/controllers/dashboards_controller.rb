class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @profile = @user.profileable
    @role_type = @user.profileable_type

    if @role_type == "UniversityProfile" && !@profile.approved?
      render :pending_approval
      return
    end
  end
end
