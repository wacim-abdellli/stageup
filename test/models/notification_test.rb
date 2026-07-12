require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @student_user = users(:mohamed_user)
    @company_user = users(:company_user)
    @offer = offers(:one)
    @submission = submissions(:one)
  end

  test "creates notification with valid attributes" do
    notif = Notification.trigger(
      recipient: @student_user,
      action: "test_action",
      message: "Test notification message.",
      notifiable: @submission
    )
    assert notif.persisted?
    assert_equal @student_user, notif.recipient
    assert_equal "test_action", notif.action
    assert_equal @submission, notif.notifiable
    assert_not notif.read
  end

  test "unread scope returns only unread notifications" do
    Notification.trigger(recipient: @student_user, action: "a", message: "Unread", notifiable: @submission)
    read = Notification.trigger(recipient: @student_user, action: "b", message: "Read", notifiable: @submission)
    read.update!(read: true)

    assert_equal 1, @student_user.notifications.unread.count
  end

  test "mark_as_read! updates read flag" do
    notif = Notification.trigger(recipient: @student_user, action: "c", message: "Mine", notifiable: @submission)
    notif.mark_as_read!
    assert notif.reload.read
  end

  test "recent scope orders by created_at desc" do
    first = Notification.trigger(recipient: @student_user, action: "d", message: "First", notifiable: @submission)
    second = Notification.trigger(recipient: @student_user, action: "e", message: "Second", notifiable: @submission)

    assert_equal [second, first], Notification.recent.to_a
  end
end
