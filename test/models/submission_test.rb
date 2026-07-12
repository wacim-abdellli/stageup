require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  setup do
    @student = student_profiles(:mohamed)
    @mission = missions(:one)
    # Use a dedicated offer not tied to any fixture submission to avoid uniqueness conflicts
    @offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Test Offer",
      description: "For model tests",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
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
    assert_includes sub.errors[:github_link], "must be a valid HTTP/HTTPS URL"
  end

  test "rejects github_link with trailing injection characters" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/repo --hack"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:github_link], "must be a valid HTTP/HTTPS URL"
  end

  test "rejects github_link with leading dashes" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "--option=http://evil.com"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:github_link], "must be a valid HTTP/HTTPS URL"
  end

  test "rejects github_link with shell metacharacters" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/repo;rm -rf /"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:github_link], "must be a valid HTTP/HTTPS URL"
  end

  test "should be invalid with submitted status and no submitted_at" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/myusername/myproject"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:submitted_at], "can't be blank"
  end

  test "should be valid with submitted status and good link format" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/myusername/myproject",
      submitted_at: Time.current
    )
    assert sub.valid?
  end

  test "should be valid with submitted status and no link for CV-only offer" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: nil,
      status: "submitted",
      submitted_at: Time.current
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

  test "should first-time expire via job with 0 penalty warning" do
    @student.commitment_events.destroy_all
    @student.update_columns(commitment_score: 100.0)

    sub = submissions(:one)
    sub.update_columns(created_at: 3.days.ago, status: "started")

    ResolveExpiredSubmissionsJob.perform_now

    sub.reload
    assert_equal "expired", sub.status

    @student.reload
    event = @student.commitment_events.last
    assert_not_nil event
    assert_equal "student_mission_expired", event.event_type
    assert_equal 0.0, event.score_delta
    assert_includes event.description, "First-time warning"
    assert_equal 100.0, @student.commitment_score
  end

  test "should apply -10 penalty on second expiration via job" do
    @student.commitment_events.destroy_all
    @student.update_columns(commitment_score: 100.0)

    # Create a prior expiration event
    @student.commitment_events.create!(
      event_type: "student_mission_expired",
      score_delta: 0.0,
      description: "First-time warning"
    )

    sub = submissions(:one)
    sub.update_columns(created_at: 3.days.ago, status: "started")

    ResolveExpiredSubmissionsJob.perform_now

    sub.reload
    assert_equal "expired", sub.status

    @student.reload
    event = @student.commitment_events.last
    assert_not_nil event
    assert_equal "student_mission_expired", event.event_type
    assert_equal(-10.0, event.score_delta)
    assert_not_includes event.description, "First-time"
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

  test "should require double confirmation to mark completed" do
    sub = submissions(:one)
    sub.update_columns(status: "accepted", student_confirmed_completed: false, company_confirmed_completed: false)
    
    # 1. Student confirms completion
    sub.confirm_completion_by!("StudentProfile")
    assert sub.student_confirmed_completed
    assert_not sub.company_confirmed_completed
    assert_equal "accepted", sub.status
    assert_not_nil sub.first_completion_confirmed_at

    # 2. Company confirms completion
    sub.confirm_completion_by!("CompanyProfile")
    assert sub.company_confirmed_completed
    assert_equal "completed", sub.status
    
    # Assert score was bumped for mohamed
    @student.reload
    assert_equal "student_completed_internship", @student.commitment_events.last.event_type
    assert_equal 15.0, @student.commitment_events.last.score_delta
  end

  test "should reject duplicate application to same offer" do
    other_offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Uniqueness Test Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    Submission.create!(
      student_profile: @student,
      offer: other_offer,
      mission: @mission,
      status: "started"
    )
    dup = Submission.new(
      student_profile: @student,
      offer: other_offer,
      mission: @mission,
      status: "started"
    )
    assert_not dup.valid?
    assert_includes dup.errors[:student_profile_id], "has already applied to this offer"
  end

  test "should raise on confirm_completion_by! when status is not accepted" do
    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "started"
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      sub.confirm_completion_by!("StudentProfile")
    end

    sub = Submission.new(
      student_profile: @student,
      offer: @offer,
      mission: @mission,
      status: "submitted",
      github_link: "https://github.com/test",
      submitted_at: Time.current
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      sub.confirm_completion_by!("CompanyProfile")
    end
  end

  test "should auto-complete via job after 7 days if only one side has confirmed completion" do
    @student.commitment_events.destroy_all
    @student.commitment_events.create!(event_type: "student_mission_expired", score_delta: -20.0, description: "Initial penalty")
    @student.recalculate_commitment_score!
    assert_equal 80.0, @student.commitment_score

    sub = submissions(:one)
    sub.update_columns(
      status: "accepted",
      student_confirmed_completed: true,
      company_confirmed_completed: false,
      first_completion_confirmed_at: 8.days.ago
    )

    ResolveExpiredSubmissionsJob.perform_now

    sub.reload
    assert_equal "completed", sub.status
    assert sub.student_confirmed_completed
    assert sub.company_confirmed_completed

    @student.reload
    assert_equal 95.0, @student.commitment_score
    assert_equal "student_completed_internship", @student.commitment_events.last.event_type
  end
end
