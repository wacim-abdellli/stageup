require "test_helper"

class CompanyProfileTest < ActiveSupport::TestCase
  test "should default commitment_score to 100.0" do
    profile = CompanyProfile.create(name: "New Corp", offers_count: 0)
    assert_equal 100.0, profile.commitment_score
  end

  test "recalculate_commitment_score! should sum score_delta from commitment events" do
    profile = company_profiles(:one)

    profile.commitment_events.create!(event_type: "company_responded_on_time", score_delta: 1.0, description: "On time response")
    profile.commitment_events.create!(event_type: "company_responded_late", score_delta: -5.0, description: "Late response")
    profile.recalculate_commitment_score!

    assert_equal 96.0, profile.commitment_score
  end

  test "recalculate_commitment_score! should clamp between 0 and 100" do
    profile = company_profiles(:two)

    profile.commitment_events.create!(event_type: "company_ghosted_offer", score_delta: -200.0, description: "Many ghosted offers")
    profile.recalculate_commitment_score!

    assert_equal 0.0, profile.commitment_score
  end
end
