# frozen_string_literal: true

require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @student_user  = users(:mohamed_user)
    @company_user  = users(:company_user)
    @third_user    = users(:cyrine_user)
    @submission    = submissions(:completed)
  end

  test "guest cannot access new review" do
    get new_submission_review_path(@submission)
    assert_redirected_to new_user_session_path
  end

  test "guest cannot create review" do
    post submission_reviews_path(@submission), params: { review: { rating: 5, comment: "Great internship experience!" } }
    assert_redirected_to new_user_session_path
  end

  test "non-participant cannot view new review form" do
    sign_in @third_user
    get new_submission_review_path(@submission)
    assert_redirected_to dashboard_path
    assert_match /not authorized/, flash[:alert]
  end

  test "non-participant cannot create review" do
    sign_in @third_user
    post submission_reviews_path(@submission), params: { review: { rating: 5, comment: "Great internship experience!" } }
    assert_redirected_to dashboard_path
  end

  test "cannot review a non-completed submission" do
    pending_submission = submissions(:accepted)
    sign_in @student_user
    get new_submission_review_path(pending_submission)
    assert_redirected_to dashboard_path
    assert_match /not been marked as completed/, flash[:alert]
  end

  test "cannot submit a second review for the same submission" do
    @submission.reviews.create!(
      author: @student_user,
      receiver: @company_user,
      rating: 4,
      comment: "Good internship overall."
    )
    sign_in @student_user
    post submission_reviews_path(@submission), params: { review: { rating: 5, comment: "Another review attempt." } }
    assert_redirected_to dashboard_path
    assert_match /already submitted/, flash[:alert]
  end

  test "student can submit a review for completed internship" do
    sign_in @student_user
    assert_difference "Review.count", 1 do
      post submission_reviews_path(@submission), params: {
        review: { rating: 5, comment: "Excellent mentorship and real-world experience." }
      }
    end
    assert_redirected_to dashboard_path
    assert_match /submitted successfully/, flash[:notice]
  end

  test "company can submit a review for completed internship" do
    sign_in @company_user
    assert_difference "Review.count", 1 do
      post submission_reviews_path(@submission), params: {
        review: { rating: 4, comment: "Reliable and technically strong student." }
      }
    end
    assert_redirected_to dashboard_path
  end
end
