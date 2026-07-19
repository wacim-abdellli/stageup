require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "student registration with unapproved university domain is rejected" do
    assert_no_difference [ "User.count", "StudentProfile.count" ] do
      post student_registration_path, params: {
        user: { email: "student@unapproved.tn", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_response :success
    assert_select ".flash-alert", text: "Please fix the errors below to complete your registration."
  end

  test "student registration with approved university domain succeeds" do
    assert_difference [ "User.count", "StudentProfile.count" ], 1 do
      post student_registration_path, params: {
        user: { email: "student@isetsf.rnu.tn", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "student registration with no university domain succeeds" do
    assert_difference [ "User.count", "StudentProfile.count" ], 1 do
      post student_registration_path, params: {
        user: { email: "student@gmail.com", password: "password12345", password_confirmation: "password12345" },
        student_profile: { first_name: "Test", last_name: "Student", major: "CS", graduation_year: 2027 }
      }
    end
    assert_redirected_to dashboard_path
  end
end
