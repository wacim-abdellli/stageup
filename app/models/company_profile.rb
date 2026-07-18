class CompanyProfile < ApplicationRecord
  has_one :user, as: :profileable, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :submissions, through: :offers
  has_many :commitment_events, as: :profileable, dependent: :destroy

  include Rateable

  validates :name, presence: true

  def recalculate_commitment_score!
    with_lock do
      base = 100.0
      delta = commitment_events.sum(:score_delta)
      new_score = (base + delta).clamp(0.0, 100.0)
      update!(commitment_score: new_score)
    end
  end

  def apply_commitment_event!(event_type:, score_delta:, description:)
    with_lock do
      commitment_events.create!(
        event_type: event_type,
        score_delta: score_delta,
        description: description
      )
      new_score = (commitment_score + score_delta).clamp(0.0, 100.0)
      update_columns(commitment_score: new_score)
    end
  end

  def recalculate_metrics!
    with_lock do
      total_apps = submissions.where.not(status: %w[started abandoned expired])
      responded_apps = total_apps.where.not(responded_at: nil)

      rate = if total_apps.any?
               (responded_apps.count.to_f / total_apps.count * 100).round(1)
             else
               100.0
             end

      avg_time = responded_apps
                   .where.not(submitted_at: nil)
                   .pick(Arel.sql("AVG(EXTRACT(EPOCH FROM (responded_at - submitted_at)) / 3600.0)"))
                   &.round(1) || 0.0

      update!(
        response_rate: rate,
        avg_response_time_hours: avg_time,
        offers_count: offers.where(status: "active").count
      )
    end
  end

end
