# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 20

  def index
    page = (params[:page] || 1).to_i.clamp(1, Float::INFINITY)
    @notifications = current_user.notifications.recent.limit(PER_PAGE).offset((page - 1) * PER_PAGE)
    @unread_count = current_user.notifications.unread.count
    @current_page = page
    @total_pages = (current_user.notifications.count.to_f / PER_PAGE).ceil
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
