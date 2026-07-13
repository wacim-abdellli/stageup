# frozen_string_literal: true
module Rateable
  extend ActiveSupport::Concern
  def average_rating
    return nil unless user
    return @average_rating if defined?(@average_rating)
    result = Review.where(receiver: user).pick("AVG(rating)")
    @average_rating = result ? result.to_f.round(1) : nil
  end
  def reviews_received_count
    return 0 unless user
    return @reviews_received_count if defined?(@reviews_received_count)
    @reviews_received_count = Review.where(receiver: user).count
  end
end
