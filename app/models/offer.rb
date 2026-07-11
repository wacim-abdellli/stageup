class Offer < ApplicationRecord
  belongs_to :company_profile
  has_one :mission, dependent: :destroy
  has_many :submissions, dependent: :destroy

  accepts_nested_attributes_for :mission, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :description, presence: true
  validates :stage_type, presence: true, inclusion: { in: %w[PFE PFA initiation free] }
  validates :spots, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :work_mode, presence: true, inclusion: { in: %w[onsite remote hybrid] }
  validates :status, presence: true, inclusion: { in: %w[draft active filled archived] }
end
