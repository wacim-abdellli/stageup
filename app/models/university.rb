# frozen_string_literal: true

class University < ApplicationRecord
  has_many :student_profiles, dependent: :nullify
  has_many :university_profiles, dependent: :destroy

  validates :name, presence: true
  validates :email_domain, presence: true, uniqueness: { case_sensitive: false }
end
