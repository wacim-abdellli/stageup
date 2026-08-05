# frozen_string_literal: true

class InternshipAgreement < ApplicationRecord
  belongs_to :submission
  has_one :student_profile, through: :submission
  has_one :university, through: :student_profile
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_must_be_after_start_date
  validate :tunisian_legal_duration_rules
  validates :status, presence: true, inclusion: { in: %w[pending_signatures fully_executed declined] }
  validates :rejection_reason, presence: true, if: -> { status == "declined" }
  validates :verification_token, uniqueness: true, allow_nil: true

  before_create :generate_verification_token

  def sign_by!(role)
    with_lock do
      if status == "fully_executed"
        errors.add(:base, "Agreement is already fully executed")
        raise ActiveRecord::RecordInvalid, self
      end

      if status == "declined"
        errors.add(:base, "Agreement has been declined")
        raise ActiveRecord::RecordInvalid, self
      end

      case role
      when "StudentProfile"
        if student_signed_at.present?
          errors.add(:base, "Student has already signed this agreement")
          raise ActiveRecord::RecordInvalid, self
        end
        self.student_signed_at = Time.current
      when "CompanyProfile"
        if company_signed_at.present?
          errors.add(:base, "Company has already signed this agreement")
          raise ActiveRecord::RecordInvalid, self
        end
        self.company_signed_at = Time.current
      when "UniversityProfile"
        if university_signed_at.present?
          errors.add(:base, "University coordinator has already signed this agreement")
          raise ActiveRecord::RecordInvalid, self
        end
        self.university_signed_at = Time.current
      end

      if student_signed_at.present? && company_signed_at.present? && university_signed_at.present?
        self.status = "fully_executed"
      end

      save!
    end
  end

  def pending_signatories
    pending = []
    pending << "Student" if student_signed_at.nil?
    pending << "Employer" if company_signed_at.nil?
    pending << "University Coordinator" if university_signed_at.nil?
    pending
  end

  private

  def generate_verification_token
    self.verification_token ||= SecureRandom.urlsafe_base64(16)
  end

  def end_date_must_be_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def tunisian_legal_duration_rules
    return unless start_date.present? && end_date.present?

    days = (end_date - start_date).to_i
    stage_type = submission&.offer&.stage_type.to_s.upcase

    case stage_type
    when "PFE"
      if days < 120
        errors.add(:end_date, "for a PFE (Graduation Project) must be at least 4 months (120 days) under Tunisian Higher Education law (selected: #{days} days).")
      elsif days > 180
        errors.add(:end_date, "for a PFE cannot exceed 6 months (180 days) under Tunisian Higher Education law.")
      end
    when "PFA"
      if days < 60
        errors.add(:end_date, "for a PFA (Mid-Studies Project) must be at least 2 months (60 days) under Tunisian law (selected: #{days} days).")
      end
    when "INITIATION", "OUVRIER"
      if days < 30
        errors.add(:end_date, "for a Stage d'Initiation must be at least 1 month (30 days) under Tunisian law.")
      end
    else
      if days < 30
        errors.add(:end_date, "must be at least 30 days under Tunisian internship regulations.")
      end
    end
  end
end
