class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied. You are not authorized to view this page." unless current_user.admin?
  end
end
