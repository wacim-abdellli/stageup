require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  setup do
    @student = student_profiles(:mohamed)
    @offer = offers(:one)
    @mission = missions(:one)
  end

  test "should be valid with started status and no link" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "started"
    )
    assert sub.valid?
  end

  test "should be invalid with submitted status and no link" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:github_link], "can't be blank"
  end

  test "should be invalid with submitted status and bad link format" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "invalid-url"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:github_link], "must be a valid URL"
  end

  test "should be valid with submitted status and good link format" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/myusername/myproject"
    )
    assert sub.valid?
  end

  test "should validate status inclusion" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "invalid_status"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:status], "is not included in the list"
  end

  test "should trigger check_and_expire! and apply student penalty on load if past 48 hours" do
    # Clear existing events for mohamed so we start with a clean score of 100
    @student.commitment_events.destroy_all
    @student.update_columns(commitment_score: 100.0)

    # Get the existing fixture submission
    sub = submissions(:one)
    
    # Force created_at to 3 days ago, bypassing callbacks, and reset status to started
    sub.update_columns(created_at: 3.days.ago, status: "started")

    # Reloading from database should trigger after_initialize callback and lazy expiry
    reloaded_sub = Submission.find(sub.id)
    
    assert_equal "expired", reloaded_sub.status
    
    # Reload student to clear association cache and check events + score
    @student.reload
    event = @student.commitment_events.last
    assert_not_nil event
    assert_equal "student_mission_expired", event.event_type
    assert_equal -10.0, event.score_delta
    assert_equal 90.0, @student.commitment_score
  end

  test "should recalculate company metrics correctly" do
    company = company_profiles(:one)
    offer = offers(:one)
    
    # Clear preexisting submissions
    offer.submissions.destroy_all
    
    # Create an active application
    sub = Submission.create!(
      student_profile: @student,
      offer: offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/test",
      submitted_at: 2.hours.ago
    )

    company.recalculate_metrics!
    
    # Total apps = 1, responded = 0 -> response_rate = 0%
    assert_equal 0.0, company.response_rate
    assert_equal 0.0, company.avg_response_time_hours

    # Respond to application (simulate accept)
    sub.update!(
      status: "accepted",
      responded_at: Time.current
    )
    
    company.recalculate_metrics!
    
    # Total apps = 1, responded = 1 -> response_rate = 100%
    assert_equal 100.0, company.response_rate
    # Avg response time should be ~2 hours
    assert_in_delta 2.0, company.avg_response_time_hours, 0.1
  end
end
