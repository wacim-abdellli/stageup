require "test_helper"

class StudentProfileTest < ActiveSupport::TestCase
  test "should be invalid without first_name" do
    profile = StudentProfile.new(last_name: "Ali", graduation_year: 2027)
    assert_not profile.valid?
    assert_includes profile.errors[:first_name], "can't be blank"
  end

  test "should be invalid without last_name" do
    profile = StudentProfile.new(first_name: "Mohamed", graduation_year: 2027)
    assert_not profile.valid?
    assert_includes profile.errors[:last_name], "can't be blank"
  end

  test "should default commitment_score to 100.0" do
    profile = StudentProfile.create(first_name: "Mohamed", last_name: "Ali")
    assert_equal 100.0, profile.commitment_score
  end

  test "should validate numericality of graduation_year" do
    profile = StudentProfile.new(first_name: "Mohamed", last_name: "Ali", graduation_year: "invalid_year")
    assert_not profile.valid?
    assert_includes profile.errors[:graduation_year], "is not a number"
  end

  test "should parse domain and match university correctly" do
    email = "student@isetsf.rnu.tn"
    domain = email.split('@').last.to_s.downcase
    
    matched_uni = University.find_by(email_domain: domain)
    assert_not_nil matched_uni
    assert_equal "ISET Sfax", matched_uni.name

    profile = StudentProfile.create!(
      first_name: "Amine",
      last_name: "Trabelsi",
      university: matched_uni
    )
    assert_equal matched_uni, profile.university
  end
end
