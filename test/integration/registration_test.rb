require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  test "successful student registration creates user and profile" do
    assert_difference -> { User.count } => 1, -> { StudentProfile.count } => 1 do
      post student_registration_path, params: {
        user: {
          email: "newstudent@iset.tn",
          password: "password12345",
          password_confirmation: "password12345"
        },
        student_profile: {
          first_name: "Test",
          last_name: "Student",
          phone: "12345678",
          major: "Computer Science",
          graduation_year: 2027,
          bio: "Looking for an internship"
        }
      }
    end

    new_user = User.last
    assert_equal "newstudent@iset.tn", new_user.email
    assert_equal "StudentProfile", new_user.profileable_type
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
  end

  test "successful company registration creates user and profile" do
    assert_difference -> { User.count } => 1, -> { CompanyProfile.count } => 1 do
      post company_registration_path, params: {
        user: {
          email: "recruiter@innovate.tn",
          password: "password12345",
          password_confirmation: "password12345"
        },
        company_profile: {
          name: "Innovate Tech",
          website: "https://innovate.tn",
          description: "High tech solutions provider"
        }
      }
    end

    new_user = User.last
    assert_equal "recruiter@innovate.tn", new_user.email
    assert_equal "CompanyProfile", new_user.profileable_type
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
  end
end
