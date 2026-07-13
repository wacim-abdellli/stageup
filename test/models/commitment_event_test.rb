# frozen_string_literal: true

require "test_helper"

class CommitmentEventTest < ActiveSupport::TestCase
  test "is valid with all required fields" do
    event = CommitmentEvent.new(
      profileable: student_profiles(:mohamed),
      event_type: "student_completed_internship",
      score_delta: 15.0,
      description: "Completed internship at Test Corp."
    )
    assert event.valid?
  end

  test "is invalid without event_type" do
    event = commitment_events(:one)
    event.event_type = nil
    assert_not event.valid?
  end

  test "is invalid with unknown event_type" do
    event = commitment_events(:one)
    event.event_type = "made_up_event"
    assert_not event.valid?
    assert_includes event.errors[:event_type], "is not included in the list"
  end

  test "is invalid without score_delta" do
    event = commitment_events(:one)
    event.score_delta = nil
    assert_not event.valid?
  end

  test "is invalid without description" do
    event = commitment_events(:one)
    event.description = nil
    assert_not event.valid?
  end
end
