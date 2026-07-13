# frozen_string_literal: true

require "test_helper"

class MissionTest < ActiveSupport::TestCase
  test "is valid with all required fields" do
    mission = missions(:one)
    assert mission.valid?
  end

  test "is invalid without title" do
    mission = missions(:one)
    mission.title = nil
    assert_not mission.valid?
  end

  test "is invalid with title over 200 characters" do
    mission = missions(:one)
    mission.title = "a" * 201
    assert_not mission.valid?
  end

  test "is invalid without instructions" do
    mission = missions(:one)
    mission.instructions = nil
    assert_not mission.valid?
  end

  test "is invalid with non-integer duration" do
    mission = missions(:one)
    mission.estimated_duration_minutes = 1.5
    assert_not mission.valid?
  end

  test "is invalid with zero duration" do
    mission = missions(:one)
    mission.estimated_duration_minutes = 0
    assert_not mission.valid?
  end

  test "is invalid with negative duration" do
    mission = missions(:one)
    mission.estimated_duration_minutes = -60
    assert_not mission.valid?
  end
end
