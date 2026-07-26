# frozen_string_literal: true

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    return reject unless current_user

    stream_from "notifications:user_#{current_user.id}"
  end

  def unsubscribed; end
end
