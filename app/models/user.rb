class User < ApplicationRecord
  belongs_to :profileable, polymorphic: true
  has_many :notifications, as: :recipient, dependent: :destroy

  validates :profileable, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable

  validate :email_domain_must_be_approved, on: :create

  private

  def email_domain_must_be_approved
    return unless profileable_type == "StudentProfile" && email.present?

    domain = email.split("@").last.to_s.downcase
    matched_uni = University.find_by(email_domain: domain)
    return unless matched_uni
    return if matched_uni.approved?

    errors.add(:email, "domain '#{domain}' belongs to a university that is not yet approved on StageUp")
  end
end
