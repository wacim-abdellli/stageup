class Submission < ApplicationRecord
  belongs_to :student_profile
  belongs_to :offer
  belongs_to :mission, optional: true

  validates :status, presence: true, inclusion: { in: %w[started submitted under_review accepted rejected completed abandoned expired] }
  validates :github_link, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: :submitted?

  after_initialize :check_and_expire!, if: :persisted?

  def submitted?
    status == "submitted"
  end

  def check_and_expire!
    if status == "started" && created_at && created_at < 48.hours.ago
      update_columns(status: "expired")
      
      student_profile.commitment_events.create!(
        event_type: "student_mission_expired",
        score_delta: -10.0,
        description: "Proof mission for '#{offer.title}' expired after 48 hours."
      )
      student_profile.recalculate_commitment_score!
    end
  end
end
