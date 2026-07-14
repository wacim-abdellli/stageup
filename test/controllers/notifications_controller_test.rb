require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_user = users(:mohamed_user)
    @submission = submissions(:one)
    @notification = Notification.trigger(
      recipient: @student_user,
      action: "application_received",
      message: "You have a test notification.",
      notifiable: @submission
    )
  end

  test "index shows notifications for authenticated user" do
    sign_in @student_user
    get notifications_path
    assert_response :success
    assert_select "p", text: "You have a test notification."
  end

  test "index redirects unauthenticated user" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "update marks notification as read" do
    sign_in @student_user
    patch notification_path(@notification)
    assert_redirected_to notifications_path
    assert @notification.reload.read
  end

  test "read_all marks all notifications as read" do
    sign_in @student_user
    Notification.trigger(recipient: @student_user, action: "application_accepted", message: "Second", notifiable: @submission)
    assert_equal 2, @student_user.notifications.unread.count

    post read_all_notifications_path
    assert_redirected_to notifications_path
    assert_equal 0, @student_user.notifications.unread.count
  end

  test "shows empty state when no notifications" do
    sign_in @student_user
    @student_user.notifications.destroy_all
    get notifications_path
    assert_response :success
    assert_select "h3", text: "All Caught Up"
  end
end
