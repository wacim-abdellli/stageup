require "test_helper"

class ReputationTrackerJobTest < ActiveJob::TestCase
  test "should expire old submitted submissions and log ghosting events" do
    profile = student_profiles(:cyrine)
    company = company_profiles(:two)
    new_offer = Offer.create!(
      company_profile: company,
      title: "Ghosted Offer",
      description: "Test",
      stage_type: "PFE",
      spots: 1,
      location: "Sfax",
      work_mode: "onsite",
      status: "active"
    )

    sub = Submission.create!(
      student_profile: profile,
      offer: new_offer,
      status: "submitted",
      submitted_at: 15.days.ago
    )

    assert_changes -> { company.commitment_events.count }, from: 0, to: 1 do
      assert_changes -> { profile.commitment_events.count }, from: 0, to: 1 do
        ReputationTrackerJob.perform_now
      end
    end

    sub.reload
    assert_equal "expired", sub.status

    company_event = company.commitment_events.last
    assert_equal "company_ghosted_offer", company_event.event_type
    assert_equal(-15.0, company_event.score_delta)

    student_event = profile.commitment_events.last
    assert_equal "student_ghosted_offer", student_event.event_type
    assert_equal 0.0, student_event.score_delta

    company.reload
    assert_equal 85.0, company.commitment_score
  end

  test "should not touch recent submitted submissions" do
    profile = student_profiles(:mohamed)
    new_offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Recent Offer",
      description: "Test",
      stage_type: "PFE",
      spots: 1,
      location: "Sfax",
      work_mode: "onsite",
      status: "active"
    )
    sub = Submission.create!(
      student_profile: profile,
      offer: new_offer,
      status: "submitted",
      submitted_at: 1.day.ago
    )

    ReputationTrackerJob.perform_now
    sub.reload
    assert_equal "submitted", sub.status
  end
end
