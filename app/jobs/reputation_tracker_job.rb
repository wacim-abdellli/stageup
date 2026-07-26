# frozen_string_literal: true

class ReputationTrackerJob < ApplicationJob
  queue_as :default

  def perform
    Submission.where(status: %w[submitted under_review])
          .where("submitted_at < ?", 14.days.ago)
          .includes(offer: :company_profile, student_profile: :user)
          .find_each do |sub|
      ActiveRecord::Base.transaction do
        updated = Submission.where(id: sub.id, status: %w[submitted under_review])
                    .update_all(status: "expired", responded_at: Time.current, updated_at: Time.current)
        next if updated == 0

        company = sub.offer.company_profile
        company.commitment_events.create!(
          event_type: "company_ghosted_offer",
          score_delta: -15.0,
          description: "Failed to respond to application for '#{sub.offer.title}' within 14 days."
        )

        student = sub.student_profile
        student.commitment_events.create!(
          event_type: "student_ghosted_offer",
          score_delta: 0.0,
          description: "Company never responded to your application for '#{sub.offer.title}'."
        )

        company.recalculate_metrics!
        company.recalculate_commitment_score!

        Notification.trigger(
          recipient: student.user,
          action: "application_ghosted",
          message: "The company did not respond to your application for #{sub.offer.title} within 14 days. It has been automatically expired.",
          notifiable: sub
        )
      end
    end
  end
end
