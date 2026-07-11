require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "approved university coordinator can load dashboard and sees stats" do
    sign_in users(:university_user)
    get dashboard_url
    assert_response :success
    assert_select "td", text: /Ben Ali/
    assert_select ".mb-6", text: "Total Students Enrolled"
    assert_select "strong", text: "1"
    assert_match "100.0", @response.body
  end

  test "pending university coordinator sees pending approval view" do
    sign_in users(:pending_university_user)
    get dashboard_url
    assert_response :success
    assert_select "h2", text: "Verification Pending"
  end

  test "guest is redirected to sign in" do
    get dashboard_url
    assert_redirected_to new_user_session_path
  end
end
