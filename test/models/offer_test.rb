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

  test "match_percentage_for returns 100 for perfect match with all skills, major, and high score" do
    @offer.stage_type = "PFE"
    @offer.skills << [ @rails, @react ]
    @student.major = "Software Engineering"
    @student.commitment_score = 100.0
    @student.skills << [ @rails, @react ]

    assert_equal 100, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for returns > 0 when student has 0 skills due to major and readiness" do
    @offer.stage_type = "PFE"
    @offer.skills << [ @rails ]
    @student.skills.clear
    @student.major = "Computer Science"
    @student.commitment_score = 80.0

    # Skills: 0, Major: 25, Readiness: 15 -> Total: 40
    score = @offer.match_percentage_for(@student)
    assert_operator score, :>, 0
    assert_equal 40, score
  end

  test "commitment_readiness_score scales proportionally for score under 80" do
    @student.commitment_score = 40.0
    breakdown = @offer.match_breakdown_for(@student)

    # 40 / 80 * 15 = 7.5
    assert_equal 7.5, breakdown[:readiness]
    assert_operator breakdown[:readiness], :<, 15.0
  end

  test "match_breakdown_for returns structured breakdown hash" do
    @offer.stage_type = "initiation"
    @student.commitment_score = 80.0
    breakdown = @offer.match_breakdown_for(@student)

    assert_kind_of Hash, breakdown
    assert_includes breakdown.keys, :skill
    assert_includes breakdown.keys, :major
    assert_includes breakdown.keys, :readiness
    assert_includes breakdown.keys, :total
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
