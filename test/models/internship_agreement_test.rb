require "test_helper"

class InternshipAgreementTest < ActiveSupport::TestCase
  setup do
    @submission = submissions(:one)
  end

  def valid_agreement
    InternshipAgreement.new(
      submission: @submission,
      start_date: Date.today,
      end_date: Date.today + 90
    )
  end

  test "should be valid with valid attributes" do
    assert valid_agreement.valid?
  end

  test "should be invalid without start_date" do
    agreement = valid_agreement
    agreement.start_date = nil
    assert_not agreement.valid?
    assert_includes agreement.errors[:start_date], "can't be blank"
  end

  test "should be invalid without end_date" do
    agreement = valid_agreement
    agreement.end_date = nil
    assert_not agreement.valid?
    assert_includes agreement.errors[:end_date], "can't be blank"
  end

  test "should be invalid if end_date is before start_date" do
    agreement = valid_agreement
    agreement.start_date = Date.today + 10
    agreement.end_date = Date.today
    assert_not agreement.valid?
    assert_includes agreement.errors[:end_date], "must be after the start date"
  end

  test "should be invalid if end_date equals start_date" do
    agreement = valid_agreement
    agreement.start_date = Date.today
    agreement.end_date = Date.today
    assert_not agreement.valid?
    assert_includes agreement.errors[:end_date], "must be after the start date"
  end

  test "should validate status inclusion" do
    agreement = valid_agreement
    agreement.status = "invalid_status"
    assert_not agreement.valid?
    assert_includes agreement.errors[:status], "is not included in the list"
  end

  test "sign_by! as student sets student_signed_at" do
    agreement = valid_agreement
    agreement.save!

    assert_nil agreement.student_signed_at
    agreement.sign_by!("StudentProfile")
    assert_not_nil agreement.reload.student_signed_at
    assert_equal "pending_signatures", agreement.status
  end

  test "sign_by! as company sets company_signed_at" do
    agreement = valid_agreement
    agreement.save!

    assert_nil agreement.company_signed_at
    agreement.sign_by!("CompanyProfile")
    assert_not_nil agreement.reload.company_signed_at
  end

  test "sign_by! as university sets university_signed_at" do
    agreement = valid_agreement
    agreement.save!

    assert_nil agreement.university_signed_at
    agreement.sign_by!("UniversityProfile")
    assert_not_nil agreement.reload.university_signed_at
  end

  test "sign_by! updates status to fully_executed when all three sign" do
    agreement = valid_agreement
    agreement.save!

    agreement.sign_by!("StudentProfile")
    agreement.sign_by!("CompanyProfile")
    agreement.sign_by!("UniversityProfile")

    agreement.reload
    assert_equal "fully_executed", agreement.status
    assert_not_nil agreement.student_signed_at
    assert_not_nil agreement.company_signed_at
    assert_not_nil agreement.university_signed_at
  end

  test "pending_signatories lists only unsigned parties" do
    agreement = valid_agreement
    agreement.save!

    assert_equal [ "Student", "Employer", "University Coordinator" ], agreement.pending_signatories

    agreement.sign_by!("StudentProfile")
    assert_equal [ "Employer", "University Coordinator" ], agreement.reload.pending_signatories

    agreement.sign_by!("CompanyProfile")
    assert_equal [ "University Coordinator" ], agreement.reload.pending_signatories

    agreement.sign_by!("UniversityProfile")
    assert_equal [], agreement.reload.pending_signatories
  end

  test "generates a non-nil verification_token on create" do
    agreement = valid_agreement
    agreement.save!
    assert_not_nil agreement.verification_token
    assert_operator agreement.verification_token.length, :>=, 16
  end

  test "enforces uniqueness of verification_token" do
    agreement1 = valid_agreement
    agreement1.save!

    sub2 = submissions(:two)
    agreement2 = InternshipAgreement.new(
      submission: sub2,
      start_date: Date.today,
      end_date: Date.today + 90,
      verification_token: agreement1.verification_token
    )
    assert_not agreement2.valid?
    assert_includes agreement2.errors[:verification_token], "has already been taken"
  end
end
