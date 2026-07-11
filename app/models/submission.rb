class Submission < ApplicationRecord
  belongs_to :student_profile
  belongs_to :offer
  belongs_to :mission, optional: true
  has_many :reviews, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[started submitted under_review accepted rejected completed abandoned expired] }
  validates :github_link, presence: true, if: :github_link_required?
  validates :github_link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  after_initialize :check_and_resolve_status!, if: :persisted?

  def submitted?
    status == "submitted"
  end

  def github_link_required?
    mission_id.present? && status == "submitted"
  end

  def check_and_resolve_status!
    # 1. Check 48-hour mission expiry
    if status == "started" && created_at && created_at < 48.hours.ago
      update_columns(status: "expired")
      
      student_profile.commitment_events.create!(
        event_type: "student_mission_expired",
        score_delta: -10.0,
        description: "Proof mission for '#{offer.title}' expired after 48 hours."
      )
      student_profile.recalculate_commitment_score!
    end

    # 2. Check 7-day completion auto-approval
    if status == "accepted" && first_completion_confirmed_at && first_completion_confirmed_at < 7.days.ago
      update_columns(
        status: "completed",
        student_confirmed_completed: true,
        company_confirmed_completed: true,
        responded_at: Time.current
      )

      # Log completion reward for student
      student_profile.commitment_events.create!(
        event_type: "student_completed_internship",
        score_delta: 15.0,
        description: "Internship completed for '#{offer.title}' (auto-approved after 7 days)."
      )
      student_profile.recalculate_commitment_score!
    end
  end

  def confirm_completion_by!(role)
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
