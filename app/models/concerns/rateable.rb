# frozen_string_literal: true

module Rateable
  extend ActiveSupport::Concern

  def average_rating
    cached_average_rating || recalculate_average_rating!
  end

  def recalculate_average_rating!
    result = Review.where(receiver: user).pick("AVG(rating)")
    avg = result ? result.to_f.round(1) : nil
    update_columns(cached_average_rating: avg) if persisted?
    avg
  end

  def reviews_received_count
    return 0 unless user
    Review.where(receiver: user).count
  end
end
