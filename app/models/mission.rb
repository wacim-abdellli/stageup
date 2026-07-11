class Mission < ApplicationRecord
  belongs_to :offer

  validates :title, presence: true
  validates :instructions, presence: true
  validates :estimated_duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
