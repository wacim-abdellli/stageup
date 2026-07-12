require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:mohamed_user)
    @unverified_company = company_profiles(:two)
  end

  test "non-admin is redirected when accessing admin dashboard" do
    sign_in @regular_user
    get admin_dashboard_url
    assert_redirected_to root_path
    assert_equal "Access denied. You are not authorized to view this page.", flash[:alert]
  end

  test "guest is redirected to sign in" do
    get admin_dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "admin can access admin dashboard" do
    sign_in @admin_user
    get admin_dashboard_url
    assert_response :success
    assert_select "h1", text: "Admin Panel"
  end

  test "admin can approve a university coordinator" do
    sign_in @admin_user
    coord = university_profiles(:pending)
    assert_not coord.approved?

    post approve_admin_university_profile_path(coord)
    assert_redirected_to admin_dashboard_path

    coord.reload
    assert coord.approved?
  end

  test "admin can reject a university coordinator" do
    sign_in @admin_user
    coord = university_profiles(:pending)

    assert_difference "UniversityProfile.count", -1 do
      post reject_admin_university_profile_path(coord)
    end

    assert_redirected_to admin_dashboard_path
  end

  test "admin can verify a company" do
    sign_in @admin_user
    company = @unverified_company
    assert_not company.verified?

    post verify_admin_company_profile_path(company)
    assert_redirected_to admin_dashboard_path

    company.reload
    assert company.verified?
  end
end
