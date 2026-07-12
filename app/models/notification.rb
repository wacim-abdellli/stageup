class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_recipient, ->(recipient) { where(recipient: recipient) }

  def mark_as_read!
    update!(read: true)
  end

  def self.trigger(recipient:, action:, message:, notifiable:)
    create!(
      recipient: recipient,
      action: action,
      message: message,
      notifiable: notifiable
    )
  end
end
