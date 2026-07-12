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
    @offer.skills << [@rails, @react, @sql, @js]
    @student.skills << [@rails, @sql, @python]

    # Student matches 2 of 4 offer skills: 2/4 = 50%
    assert_equal 50, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for returns 100 for perfect match" do
    @offer.skills << [@rails, @react, @sql, @js]
    @student.skills << [@rails, @react, @sql, @js]

    assert_equal 100, @offer.match_percentage_for(@student)
  end

  test "match_percentage_for rounds to nearest integer" do
    @offer.skills << [@rails, @react, @sql]
    @student.skills << [@rails]

    # 1/3 = 33.33... -> 33
    assert_equal 33, @offer.match_percentage_for(@student)
  end
end
