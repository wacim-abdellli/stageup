require "test_helper"

class UserRegistrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "student registration fails with unapproved university domain" do
    assert_no_difference ["User.count", "StudentProfile.count"] do
      post student_registration_path, params: {
        user: { email: "student@unapproved.tn", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_response :success
    assert_select ".flash-alert", text: "Please fix the errors below to complete your registration."
    assert_match /not yet approved/, response.body
  end

  test "student registration succeeds with approved university domain" do
    assert_difference ["User.count", "StudentProfile.count"], 1 do
      post student_registration_path, params: {
        user: { email: "student@isetsf.rnu.tn", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "rejects email with trailing injection characters" do
    assert_no_difference ["User.count", "StudentProfile.count"] do
      post student_registration_path, params: {
        user: { email: "student@gmail.com --hack", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_response :success
    assert_select ".flash-alert", text: "Please fix the errors below to complete your registration."
  end

  test "student registration succeeds with no matching university domain" do
    assert_difference ["User.count", "StudentProfile.count"], 1 do
      post student_registration_path, params: {
        user: { email: "student@gmail.com", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_redirected_to dashboard_path
  end
end
