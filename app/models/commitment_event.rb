# frozen_string_literal: true

class CommitmentEvent < ApplicationRecord
  belongs_to :profileable, polymorphic: true

  EVENT_TYPES = %w[
    student_ghosted_offer
    student_abandoned_mission
    student_mission_expired
    student_completed_internship
    company_responded_on_time
    company_responded_late
    company_ghosted_offer
    company_cancelled_internship
  ].freeze

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
  validates :score_delta, presence: true, numericality: true
  validates :description, presence: true
end
