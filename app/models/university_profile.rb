class UniversityProfile < ApplicationRecord
  belongs_to :university
  has_one :user, as: :profileable, dependent: :destroy

  validates :admin_name, presence: true
  validates :department, presence: true
  validates :university, presence: true
end
