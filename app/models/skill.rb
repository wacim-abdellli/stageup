class Skill < ApplicationRecord
  has_and_belongs_to_many :student_profiles
  has_and_belongs_to_many :offers

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
