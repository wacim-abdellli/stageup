require "test_helper"

class OfferTest < ActiveSupport::TestCase
  setup do
    @student = student_profiles(:mohamed)
    @offer = offers(:one)
    @rails = Skill.create!(name: "Ruby on Rails")
    @react = Skill.create!(name: "React")
    @sql = Skill.create!(name: "SQL")
    @js = Skill.create!(name: "JavaScript")
    @python = Skill.create!(name: "Python")
  end

  test "match_percentage_for returns 100 when offer has no skills" do
    assert_equal 100, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for returns 0 when student has no skills" do
    @offer.skills << @rails
    assert_equal 0, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for returns correct percentage for partial match" do
    @offer.skills << [ @rails, @react, @sql, @js ]
    @student.skills << [ @rails, @sql, @python ]

    # Student matches 2 of 4 offer skills: 2/4 = 50%
    assert_equal 50, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for returns 100 for perfect match" do
    @offer.skills << [ @rails, @react, @sql, @js ]
    @student.skills << [ @rails, @react, @sql, @js ]

    assert_equal 100, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for rounds to nearest integer" do
    @offer.skills << [ @rails, @react, @sql ]
    @student.skills << [ @rails ]

    # 1/3 = 33.33... -> 33
    assert_equal 33, @offer.match_percentage_for(@student)
  end

  test "rejects invalid stage_type" do
    offer = Offer.new(
      company_profile: company_profiles(:one),
      title: "Invalid Stage",
      description: "Test",
      stage_type: "invalid_type",
      spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    assert_not offer.valid?
    assert_includes offer.errors[:stage_type], "is not included in the list"
  end

  test "rejects invalid work_mode" do
    offer = Offer.new(
      company_profile: company_profiles(:one),
      title: "Invalid Work Mode",
      description: "Test",
      stage_type: "PFE",
      spots: 1, location: "Sfax", work_mode: "invalid", status: "active"
    )
    assert_not offer.valid?
    assert_includes offer.errors[:work_mode], "is not included in the list"
  end

  test "status defaults to active in the database" do
    offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Status Test",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite"
    )
    assert_equal "active", offer.reload.status
  end
end
