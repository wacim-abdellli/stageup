# frozen_string_literal: true

class Submission < ApplicationRecord
  VALID_STATUSES = %w[started submitted under_review accepted rejected completed abandoned expired cancelled].freeze
  VALID_AUTO_VERIFICATION_STATUSES = %w[pending checking passed failed].freeze

  belongs_to :student_profile
  belongs_to :offer
  belongs_to :mission, optional: true
  has_many :reviews, dependent: :destroy
  has_one :internship_agreement, dependent: :destroy

  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :github_link, presence: true, if: :github_link_required?
  validates :github_link, format: { with: /\Ahttps?:\/\/[^\s]+\z/, message: "must be a valid HTTP/HTTPS URL" }, allow_blank: true
  validates :submitted_at, presence: true, if: :submitted?
  validates :student_profile_id, uniqueness: {
    scope: :offer_id,
    conditions: -> { where.not(status: %w[expired abandoned rejected]) },
    message: "has already applied to this offer"
  }
  validates :auto_verification_status, inclusion: { in: VALID_AUTO_VERIFICATION_STATUSES }, allow_nil: true

  def submitted?
    status == "submitted"
  end

  def github_link_required?
    mission_id.present? && status.in?(%w[submitted under_review])
  end

  def log_company_response_event!
    company = offer.company_profile
    submitted = submitted_at || created_at
    late = submitted < 14.days.ago
    event_type = late ? "company_responded_late" : "company_responded_on_time"
    delta = late ? -5.0 : +1.0
    desc = late ? "Responded late (over 14 days) to application for '#{offer.title}'" : "Responded on time (within 14 days) to application for '#{offer.title}'"
    company.commitment_events.create!(
      event_type: event_type,
      score_delta: delta,
      description: desc
    )
  end

  def confirm_completion_by!(role)
    unless status == "accepted"
      errors.add(:base, "Only accepted internships can be marked as completed.")
      raise ActiveRecord::RecordInvalid, self
    end

    if role == "StudentProfile"
      self.student_confirmed_completed = true
    elsif role == "CompanyProfile"
      self.company_confirmed_completed = true
    end

    if first_completion_confirmed_at.nil?
      self.first_completion_confirmed_at = Time.current
    end

    if student_confirmed_completed && company_confirmed_completed
      unless internship_agreement&.status == "fully_executed"
        errors.add(:base, "The internship agreement must be fully executed before completion can be confirmed.")
        raise ActiveRecord::RecordInvalid, self
      end

      self.status = "completed"
      self.responded_at = Time.current

      student_profile.commitment_events.create!(
        event_type: "student_completed_internship",
        score_delta: 15.0,
        description: "Internship successfully completed for '#{offer.title}'."
      )
    end

    save!
    student_profile.recalculate_commitment_score! if saved_change_to_status?(from: "accepted", to: "completed")
  end
end
