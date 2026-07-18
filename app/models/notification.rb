# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  VALID_ACTIONS = %w[
    application_received application_accepted application_rejected
    application_status_updated agreement_signature_requested
    agreement_declined coordinator_approved company_verified
    company_unverified internship_abandoned internship_cancelled
    internship_completed internship_auto_completed mission_expired
    application_ghosted
  ].freeze

  validates :action, presence: true, inclusion: { in: VALID_ACTIONS }
  validates :message, presence: true, length: { maximum: 500 }
  before_validation :strip_html_from_message

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
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(
      "[Notification::TriggerFailed] action=#{action} recipient=#{recipient&.id} " \
      "notifiable=#{notifiable&.class}##{notifiable&.id} error=#{e.message}"
    )
    nil
  end

  private

  def strip_html_from_message
    self.message = ActionController::Base.helpers.strip_tags(message.to_s).strip
  end
end
