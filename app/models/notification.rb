# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  after_create_commit :broadcast_to_recipient

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

  def target_path
    case notifiable
    when InternshipAgreement
      "/submissions/#{notifiable.submission_id}/internship_agreements/#{notifiable.id}"
    when Submission
      if notifiable.internship_agreement.present?
        "/submissions/#{notifiable.id}/internship_agreements/#{notifiable.internship_agreement.id}"
      elsif notifiable.offer.present?
        "/offers/#{notifiable.offer_id}"
      else
        "/dashboard"
      end
    when Offer
      "/offers/#{notifiable.id}"
    else
      "/dashboard"
    end
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

  def broadcast_to_recipient
    target_user_id = if recipient.respond_to?(:user_id) && recipient.user_id.present?
      recipient.user_id
    elsif recipient.is_a?(User)
      recipient.id
    elsif recipient.respond_to?(:user) && recipient.user.present?
      recipient.user.id
    else
      recipient_id
    end

    ActionCable.server.broadcast(
      "notifications:user_#{target_user_id}",
      {
        id:         id,
        action:     action,
        message:    message,
        created_at: created_at.iso8601
      }
    )
  end

  def strip_html_from_message
    self.message = ActionController::Base.helpers.strip_tags(message.to_s).strip
  end
end
