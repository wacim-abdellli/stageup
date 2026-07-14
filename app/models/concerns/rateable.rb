# frozen_string_literal: true
module Rateable
  extend ActiveSupport::Concern
  def average_rating
    return nil unless user
    result = Review.where(receiver: user).pick("AVG(rating)")
    result ? result.to_f.round(1) : nil
  end
  def reviews_received_count
    return 0 unless user
    Review.where(receiver: user).count
  end
end
