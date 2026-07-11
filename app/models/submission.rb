class Submission < ApplicationRecord
  belongs_to :student_profile
  belongs_to :offer
  belongs_to :mission, optional: true
  has_many :reviews, dependent: :destroy
  has_one :internship_agreement, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[started submitted under_review accepted rejected completed abandoned expired cancelled] }
  validates :github_link, presence: true, if: :github_link_required?
  validates :github_link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :submitted_at, presence: true, if: :submitted?
  validates :student_profile_id, uniqueness: { scope: :offer_id, message: "has already applied to this offer" }
  validates :auto_verification_status, inclusion: { in: %w[pending checking passed failed] }, allow_nil: true

  def submitted?
    status == "submitted"
  end

  def github_link_required?
    mission_id.present? && status == "submitted"
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
      self.status = "completed"
      self.responded_at = Time.current

      student_profile.commitment_events.build(
        event_type: "student_completed_internship",
        score_delta: 15.0,
        description: "Internship successfully completed for '#{offer.title}'."
      )
    end

    save!
    student_profile.recalculate_commitment_score! if status == "completed"
  end
end
