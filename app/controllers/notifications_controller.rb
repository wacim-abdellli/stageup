class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
    @unread_count = current_user.notifications.unread.count
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    redirect_to notifications_path, notice: "Notification marked as read."
  end

  def read_all
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
