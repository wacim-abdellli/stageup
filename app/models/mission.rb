# frozen_string_literal: true

class Mission < ApplicationRecord
  belongs_to :offer

  validates :title, presence: true, length: { maximum: 200 }
  validates :instructions, presence: true, length: { maximum: 10_000 }
  validates :estimated_duration_minutes, presence: true,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10_080 }
end
