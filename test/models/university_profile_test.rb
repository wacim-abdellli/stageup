require "test_helper"

class UniversityProfileTest < ActiveSupport::TestCase
  test "should default approved to false" do
    profile = UniversityProfile.new(
      university: universities(:enis),
      admin_name: "Test Coordinator",
      department: "CS"
    )
    assert_not profile.approved
  end

  test "should require university association" do
    profile = UniversityProfile.new(
      admin_name: "No University",
      department: "CS",
      approved: false
    )
    assert_not profile.valid?
    assert_includes profile.errors[:university], "must exist"
  end

  test "approved? predicate returns the approved boolean" do
    approved_profile = university_profiles(:ahmed)
    assert approved_profile.approved?
    assert approved_profile.approved

    pending_profile = university_profiles(:pending)
    assert_not pending_profile.approved?
    assert_not pending_profile.approved
  end
end
