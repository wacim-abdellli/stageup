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
end
