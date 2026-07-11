class CompanyProfile < ApplicationRecord
  has_one :user, as: :profileable, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :submissions, through: :offers
  has_many :commitment_events, as: :profileable, dependent: :destroy

  validates :name, presence: true

  def recalculate_metrics!
    total_apps = submissions.where.not(status: ["started", "abandoned", "expired"])
    responded_apps = total_apps.where.not(responded_at: nil)
    
    rate = total_apps.any? ? (responded_apps.count.to_f / total_apps.count * 100).round(1) : 100.0
    
    times = responded_apps.map { |s| (s.responded_at - s.submitted_at) / 1.hour }
    avg_time = times.any? ? (times.sum / times.size).round(1) : 0.0

    update!(
      response_rate: rate,
      avg_response_time_hours: avg_time,
      offers_count: offers.count
    )
  end

  def average_rating
    return nil unless user
    reviews = Review.where(receiver: user)
    reviews.any? ? (reviews.average(:rating).to_f).round(1) : nil
  end

  def reviews_received_count
    return 0 unless user
    Review.where(receiver: user).count
  end
end
