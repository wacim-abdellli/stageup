class InternshipAgreement < ApplicationRecord
  belongs_to :submission
  has_one :student_profile, through: :submission
  has_one :university, through: :student_profile

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_must_be_after_start_date
  validates :status, presence: true, inclusion: { in: %w[pending_signatures fully_executed declined] }
  validates :rejection_reason, presence: true, if: -> { status == "declined" }

  def sign_by!(role)
    case role
    when "StudentProfile"
      self.student_signed_at = Time.current
    when "CompanyProfile"
      self.company_signed_at = Time.current
    when "UniversityProfile"
      self.university_signed_at = Time.current
    end

    if student_signed_at.present? && company_signed_at.present? && university_signed_at.present?
      self.status = "fully_executed"
    end

    save!
  end

  def pending_signatories
    pending = []
    pending << "Student" if student_signed_at.nil?
    pending << "Employer" if company_signed_at.nil?
    pending << "University Coordinator" if university_signed_at.nil?
    pending
  end

  private

  def end_date_must_be_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
