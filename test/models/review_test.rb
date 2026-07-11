require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @student_user = users(:mohamed_user)
    @company_user = users(:company_user)
    @submission = submissions(:one)
  end

  test "should be invalid if submission is not completed" do
    # Submission :one has status 'started', so it is not completed
    assert_not_equal "completed", @submission.status
    
    review = Review.new(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 5,
      comment: "This was a wonderful experience with DevCorp."
    )
    assert_not review.valid?
    assert_includes review.errors[:submission], "must be marked as completed before leaving a review"
  end

  test "should be valid if submission is completed and params are good" do
    @submission.update_columns(status: "completed")
    
    review = Review.new(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 5,
      comment: "This was a wonderful experience with DevCorp."
    )
    assert review.valid?
  end

  test "should be invalid if rating is out of range" do
    @submission.update_columns(status: "completed")

    review = Review.new(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 6,
      comment: "This was a wonderful experience with DevCorp."
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be between 1 and 5"
  end

  test "should be invalid if comment is too short" do
    @submission.update_columns(status: "completed")

    review = Review.new(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 4,
      comment: "Too short"
    )
    assert_not review.valid?
    assert_includes review.errors[:comment], "must be at least 10 characters long"
  end

  test "should be invalid if author is not a participant" do
    @submission.update_columns(status: "completed")
    other_user = users(:cyrine_user) # A different student user

    review = Review.new(
      submission: @submission,
      author: other_user,
      receiver: @company_user,
      rating: 5,
      comment: "This was a wonderful experience with DevCorp."
    )
    assert_not review.valid?
    assert_includes review.errors[:author], "must be either the student or the employer for this internship"
  end

  test "should enforce unique reviews per submission and author" do
    @submission.update_columns(status: "completed")

    # Create first review
    Review.create!(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 5,
      comment: "This was a wonderful experience with DevCorp."
    )

    # Try creating second review by same author
    duplicate_review = Review.new(
      submission: @submission,
      author: @student_user,
      receiver: @company_user,
      rating: 4,
      comment: "Another review attempt by same student."
    )
    assert_not duplicate_review.valid?
    assert_includes duplicate_review.errors[:submission_id], "has already been reviewed by you"
  end
end
