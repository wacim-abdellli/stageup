# frozen_string_literal: true

class InternshipAgreement < ApplicationRecord
  belongs_to :submission
  has_one :student_profile, through: :submission
  has_one :university, through: :student_profile
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_must_be_after_start_date
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

  # Returns an advisory warning string if duration is outside typical guidelines, but does not block saving.
  def duration_warning
    return nil unless start_date.present? && end_date.present?

    days = (end_date - start_date).to_i
    stage_type = submission&.offer&.stage_type.to_s.upcase

    case stage_type
    when "PFA", "INITIATION", "OUVRIER"
      if days < 20
        "Note: PFA and 1st-year internships are typically ~30 days (1 month). Selected duration (#{days} days) is shorter than customary."
      elsif days > 45
        "Note: PFA and 1st-year internships are typically ~30 days (1 month). Selected duration (#{days} days) is longer than customary."
      end
    when "PFE"
      if days < 90
        "Note: PFE (Graduation Project) internships typically run for ~6 months (120–180 days). Selected duration (#{days} days) is shorter than customary."
      elsif days > 210
        "Note: PFE (Graduation Project) internships typically run for ~6 months (120–180 days). Selected duration (#{days} days) is longer than customary."
      end
    end
  end
end
