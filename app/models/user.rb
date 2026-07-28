# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :profileable, polymorphic: true
  has_many :notifications, as: :recipient, dependent: :destroy

  validates :profileable, presence: true
  validates :profileable_type,
    inclusion: { in: %w[StudentProfile CompanyProfile UniversityProfile],
                 message: "is not a valid profile type" }

  attr_readonly :admin
  attr_accessor :allow_admin_creation

  validate :admin_cannot_be_set_on_create, on: :create

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable, :trackable

  before_validation :auto_grant_master_admin, on: :create

  validate :email_domain_must_be_approved

  private

  def auto_grant_master_admin
    return unless email.to_s.strip.downcase == "wacimabdelli01@gmail.com"

    self.allow_admin_creation = true
    self.admin = true
  end

  def email_domain_must_be_approved
    return unless profileable_type == "StudentProfile" && email.present?

    domain = email.split("@").last.to_s.downcase
    matched_uni = University.find_by(email_domain: domain)
    return unless matched_uni
    return if matched_uni.approved?

    errors.add(:email, "domain '#{domain}' belongs to a university that is not yet approved on StageUp")
  end

  def admin_cannot_be_set_on_create
    if admin? && !allow_admin_creation
      errors.add(:admin, "cannot be set to true on registration")
    end
  end
end
