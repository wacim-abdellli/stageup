class StudentProfile < ApplicationRecord
  belongs_to :university, optional: true
  has_one :user, as: :profileable, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :commitment_events, as: :profileable, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :graduation_year, numericality: { only_integer: true, greater_than_or_equal_to: 2020 }, allow_nil: true

  def recalculate_commitment_score!
    base = 100.0
    delta = commitment_events.sum(:score_delta)
    new_score = (base + delta).clamp(0.0, 100.0)
    update!(commitment_score: new_score)
  end
end
