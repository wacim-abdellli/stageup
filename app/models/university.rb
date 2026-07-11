class University < ApplicationRecord
  has_many :student_profiles, dependent: :nullify
  has_many :university_profiles, dependent: :destroy
end
