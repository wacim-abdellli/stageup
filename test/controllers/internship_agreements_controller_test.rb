require "test_helper"

class InternshipAgreementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_user = users(:mohamed_user)
    @company_user = users(:company_user)
    @university_user = users(:university_user)
    @student_profile = student_profiles(:mohamed)
    @company_profile = company_profiles(:one)

    # Create an accepted submission for testing agreements
    @submission = Submission.create!(
      student_profile: @student_profile,
      offer: Offer.create!(
        company_profile: @company_profile,
        title: "Agreement Test Offer",
        description: "Test",
        stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
      ),
      status: "accepted",
      responded_at: Time.current
    )
  end

  test "guest user is redirected to login" do
    get new_submission_internship_agreement_path(@submission)
    assert_redirected_to new_user_session_path
  end

  test "student can see new agreement form" do
    sign_in @student_user
    get new_submission_internship_agreement_path(@submission)
    assert_response :success
  end

  test "student can create agreement" do
    sign_in @student_user
    assert_difference "InternshipAgreement.count", 1 do
      post submission_internship_agreements_path(@submission), params: {
        internship_agreement: { start_date: Date.today, end_date: Date.today + 90 }
      }
    end
    assert_redirected_to submission_internship_agreement_path(@submission, InternshipAgreement.last)
  end

  test "student can view own agreement" do
    sign_in @student_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    get submission_internship_agreement_path(@submission, agreement)
    assert_response :success
  end

  test "student can sign own agreement" do
    sign_in @student_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_redirected_to submission_internship_agreement_path(@submission, agreement)
    assert_not_nil agreement.reload.student_signed_at
  end

  test "company can sign agreement" do
    sign_in @company_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_redirected_to submission_internship_agreement_path(@submission, agreement)
    assert_not_nil agreement.reload.company_signed_at
  end

  test "university coordinator can sign agreement" do
    sign_in @university_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_redirected_to submission_internship_agreement_path(@submission, agreement)
    assert_not_nil agreement.reload.university_signed_at
  end

  test "full three-way signing executes agreement" do
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    sign_in @student_user
    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_equal "pending_signatures", agreement.reload.status

    sign_in @company_user
    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_equal "pending_signatures", agreement.reload.status

    sign_in @university_user
    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_equal "fully_executed", agreement.reload.status
  end

  test "other student cannot access agreement" do
    other_user = users(:cyrine_user)
    sign_in other_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    get submission_internship_agreement_path(@submission, agreement)
    assert_redirected_to dashboard_path
    assert_equal "You are not authorized to manage this agreement.", flash[:alert]
  end

  test "completion is blocked if agreement is pending" do
    sign_in @student_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post confirm_completion_submission_path(@submission)
    assert_redirected_to dashboard_path
    assert_equal "You cannot mark this internship as completed until the Convention de Stage is fully signed by all three parties.", flash[:alert]
  end

  test "completion is allowed if no agreement exists" do
    sign_in @student_user

    post confirm_completion_submission_path(@submission)
    assert_redirected_to dashboard_path
    assert_not_equal "You cannot mark this internship as completed until the Convention de Stage is fully signed by all three parties.", flash[:alert]
  end
end
