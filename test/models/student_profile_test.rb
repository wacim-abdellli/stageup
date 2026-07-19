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
    domain = email.split("@").last.to_s.downcase

    matched_uni = University.find_by(email_domain: domain)
    assert_not_nil matched_uni
    assert_equal "ISET Sfax", matched_uni.name

    profile = StudentProfile.create!(
      first_name: "Amine",
      last_name: "Trabelsi",
      university: matched_uni
    )
  end

  test "should allow attaching PDF CV" do
    profile = student_profiles(:mohamed)
    profile.cv.attach(io: StringIO.new("%PDF-1.4 Mock PDF Content"), filename: "test.pdf", content_type: "application/pdf")
    profile.save!
    assert profile.valid?
  end

  test "should reject non-PDF CV" do
    profile = student_profiles(:mohamed)
    profile.cv.attach(io: StringIO.new("Mock TXT Content"), filename: "test.txt", content_type: "text/plain")
    profile.save
    assert_not profile.valid?
    assert_includes profile.errors[:cv], "must be a PDF document"
  end

  test "should reject PDF with .pdf extension but wrong magic bytes" do
    profile = student_profiles(:mohamed)
    profile.cv.attach(io: StringIO.new("FakePDF content disguised"), filename: "resume.pdf", content_type: "application/pdf")
    profile.save
    assert_not profile.valid?
    assert_includes profile.errors[:cv], "file is corrupted or not a valid PDF document"
  end

  test "should calculate average rating and review counts correctly" do
    profile = student_profiles(:mohamed)
    user = users(:mohamed_user)
    other_user = users(:company_user)
    submission = submissions(:one)
    submission.update_columns(status: "completed")

    # Ensure mohamed starts with no reviews
    Review.where(receiver: user).destroy_all
    assert_nil profile.average_rating
    assert_equal 0, profile.reviews_received_count

    # Create review 1: rating 4
    Review.create!(
      submission: submission,
      author: other_user,
      receiver: user,
      rating: 4,
      comment: "Good internship cooperation."
    )

    assert_equal 4.0, profile.average_rating
    assert_equal 1, profile.reviews_received_count

    # Create review 2: rating 5
    offer2 = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Secondary Offer",
      description: "Second role",
      stage_type: "PFA",
      spots: 1,
      location: "Sfax",
      work_mode: "onsite",
      status: "active"
    )
    sub2 = Submission.create!(
      student_profile: profile,
      offer: offer2,
      status: "completed"
    )

    Review.create!(
      submission: sub2,
      author: other_user,
      receiver: user,
      rating: 5,
      comment: "Excellent work on second project."
    )

    profile.reload
    assert_equal 4.5, profile.average_rating
    assert_equal 2, profile.reviews_received_count
  end
end
