# frozen_string_literal: true

require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_user = users(:mohamed_user)
    @company_user = users(:company_user)
    @student_profile = student_profiles(:mohamed)
    @company_profile = company_profiles(:one)
  end

  test "abandon changes status to abandoned and penalizes student score" do
    sign_in @student_user

    offer = Offer.create!(
      company_profile: @company_profile,
      title: "Abandon Test Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    sub = Submission.create!(
      student_profile: @student_profile,
      offer: offer,
      status: "accepted",
      responded_at: Time.current
    )

    assert_difference -> { @student_profile.commitment_events.where(event_type: "student_abandoned_mission").count }, 1 do
      post abandon_submission_path(sub)
    end

    sub.reload
    assert_equal "abandoned", sub.status
    @student_profile.reload
    assert_equal 80.0, @student_profile.commitment_score
  end

  test "cannot apply to inactive offer" do
    sign_in @student_user

    draft_offer = Offer.create!(
      company_profile: @company_profile,
      title: "Draft Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "draft"
    )

    post submissions_path, params: { offer_id: draft_offer.id, submission: { mission_id: "" } }
    assert_redirected_to offer_path(draft_offer)
    assert_equal "You cannot apply to an inactive offer.", flash[:alert]
  end

  test "cannot update submission if status is under_review" do
    sign_in @student_user

    offer = Offer.create!(
      company_profile: @company_profile,
      title: "Update Test Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    sub = Submission.create!(
      student_profile: @student_profile,
      offer: offer,
      status: "under_review",
      submitted_at: Time.current
    )

    patch submission_path(sub), params: { submission: { github_link: "https://github.com/new" } }
    assert_redirected_to dashboard_path
    assert_equal "This submission cannot be updated.", flash[:alert]

    sub.reload
    assert_nil sub.github_link
  end

  test "cannot update submission if status is accepted" do
    sign_in @student_user

    offer = Offer.create!(
      company_profile: @company_profile,
      title: "Update Accepted Test",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    sub = Submission.create!(
      student_profile: @student_profile,
      offer: offer,
      status: "accepted",
      responded_at: Time.current
    )

    patch submission_path(sub), params: { submission: { submission_notes: "should not apply" } }
    assert_redirected_to dashboard_path
    assert_equal "This submission cannot be updated.", flash[:alert]
  end

  test "cannot double-apply to same offer" do
    sign_in @student_user

    offer = Offer.create!(
      company_profile: @company_profile,
      title: "Double Apply Test",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    Submission.create!(
      student_profile: @student_profile,
      offer: offer,
      status: "started"
    )

    assert_no_difference "Submission.count" do
      post submissions_path, params: { offer_id: offer.id, submission: { mission_id: "" } }
    end
    assert_redirected_to offer_path(offer)
  end

  test "cancel changes status to abandoned and penalizes student score via ghosting" do
    sign_in @company_user

    offer = Offer.create!(
      company_profile: @company_profile,
      title: "Cancel Test Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    sub = Submission.create!(
      student_profile: @student_profile,
      offer: offer,
      status: "accepted",
      responded_at: Time.current
    )

    assert_difference -> { @student_profile.commitment_events.where(event_type: "student_ghosted_offer").count }, 1 do
      post cancel_submission_path(sub)
    end

    sub.reload
    assert_equal "abandoned", sub.status

    student_event = @student_profile.commitment_events.where(event_type: "student_ghosted_offer").last
    assert_equal(-15.0, student_event.score_delta)
    assert_includes student_event.description, "Ghosted employer on active internship for"

    @student_profile.reload
    assert_equal 90.0, @student_profile.commitment_score
  end

  test "student can create a submission for an active offer without mission" do
    sign_in users(:mohamed_user)
    offer = offers(:no_mission)
    assert_difference "Submission.count", 1 do
      post submissions_path, params: { offer_id: offer.id }
    end
    assert_redirected_to offer_path(offer)
  end

  test "student cannot apply to an inactive offer" do
    sign_in users(:mohamed_user)
    offer = offers(:draft)
    assert_no_difference "Submission.count" do
      post submissions_path, params: { offer_id: offer.id }
    end
    assert_redirected_to offer_path(offer)
    assert_match /inactive/, flash[:alert]
  end

  test "company can accept a submitted application" do
    sign_in users(:company_user)
    submission = submissions(:submitted_submission)
    post accept_submission_path(submission)
    assert_redirected_to dashboard_path
    assert_equal "accepted", submission.reload.status
  end

  test "student cannot accept a submission" do
    sign_in users(:mohamed_user)
    submission = submissions(:submitted_submission)
    post accept_submission_path(submission)
    assert_redirected_to dashboard_path
    assert_match /Only companies/, flash[:alert]
  end

  test "company can reject a submitted application" do
    sign_in users(:company_user)
    submission = submissions(:submitted_submission)
    post reject_submission_path(submission)
    assert_redirected_to dashboard_path
    assert_equal "rejected", submission.reload.status
  end

  test "company cannot accept another company's submission" do
    sign_in users(:company_user_two)
    submission = submissions(:submitted_submission)
    assert_raises(ActiveRecord::RecordNotFound) do
      post accept_submission_path(submission)
    end
  end
end
