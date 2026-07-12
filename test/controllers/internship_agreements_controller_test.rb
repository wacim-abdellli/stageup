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

  test "completion is blocked if no agreement exists" do
    sign_in @student_user

    post confirm_completion_submission_path(@submission)
    assert_redirected_to dashboard_path
    assert_equal "You cannot mark this internship as completed until a Convention de Stage has been generated.", flash[:alert]
  end

  test "completion is allowed when agreement is fully executed" do
    sign_in @student_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90, status: "fully_executed", student_signed_at: Time.current, company_signed_at: Time.current, university_signed_at: Time.current)

    post confirm_completion_submission_path(@submission)
    assert_redirected_to dashboard_path
    assert_not_equal "You cannot mark this internship as completed until a Convention de Stage has been generated.", flash[:alert]
    assert_not_equal "You cannot mark this internship as completed until the Convention de Stage is fully signed by all three parties.", flash[:alert]
  end

  test "cannot create agreement on non-accepted submission" do
    sign_in @student_user
    pending_sub = Submission.create!(
      student_profile: @student_profile,
      offer: Offer.create!(
        company_profile: @company_profile,
        title: "Pending Offer", description: "Test",
        stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
      ),
      status: "started"
    )

    get new_submission_internship_agreement_path(pending_sub)
    assert_redirected_to dashboard_path
    assert_equal "You can only generate an agreement for an accepted internship.", flash[:alert]

    post submission_internship_agreements_path(pending_sub), params: {
      internship_agreement: { start_date: Date.today, end_date: Date.today + 90 }
    }
    assert_redirected_to dashboard_path
    assert_equal "You can only generate an agreement for an accepted internship.", flash[:alert]
  end

  test "university coordinator can decline agreement" do
    sign_in @university_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post decline_submission_internship_agreement_path(@submission, agreement), params: {
      rejection_reason: "The internship duration is too short for the required credits."
    }

    assert_redirected_to submission_internship_agreement_path(@submission, agreement)
    agreement.reload
    assert_equal "declined", agreement.status
    assert_equal "The internship duration is too short for the required credits.", agreement.rejection_reason
  end

  test "non-coordinator cannot decline agreement" do
    sign_in @student_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post decline_submission_internship_agreement_path(@submission, agreement), params: {
      rejection_reason: "Not allowed."
    }

    assert_redirected_to dashboard_path
    assert_equal "pending_signatures", agreement.reload.status
  end

  test "unapproved coordinator cannot sign agreement" do
    pending_coord = users(:pending_university_user)
    sign_in pending_coord

    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post sign_submission_internship_agreement_path(@submission, agreement)
    assert_redirected_to dashboard_path
    assert_equal "You are not authorized to manage this agreement.", flash[:alert]
    assert_nil agreement.reload.university_signed_at
  end

  test "unapproved coordinator cannot decline agreement" do
    pending_coord = users(:pending_university_user)
    sign_in pending_coord

    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post decline_submission_internship_agreement_path(@submission, agreement), params: {
      rejection_reason: "Some reason."
    }
    assert_redirected_to dashboard_path
    assert_equal "pending_signatures", agreement.reload.status
  end

  test "declining with empty rejection_reason shows validation error instead of 500" do
    sign_in @university_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    post decline_submission_internship_agreement_path(@submission, agreement), params: {
      rejection_reason: ""
    }

    assert_response :success
    assert_match /Failed to decline/, response.body
    assert_equal "pending_signatures", agreement.reload.status
  end

  test "declining creates notifications for student and company" do
    sign_in @university_user
    agreement = InternshipAgreement.create!(submission: @submission, start_date: Date.today, end_date: Date.today + 90)

    assert_difference "Notification.count", 2 do
      post decline_submission_internship_agreement_path(@submission, agreement), params: {
        rejection_reason: "Insufficient supervision details."
      }
    end

    student_notif = @student_user.notifications.last
    company_notif = @company_user.notifications.last
    assert_equal "agreement_declined", student_notif.action
    assert_equal "agreement_declined", company_notif.action
  end
end
