require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guest user should get index landing page" do
    get root_url
    assert_response :success
    assert_select "h1", /Verify Practical Skills/
  end

  test "logged in student should be redirected to dashboard from root" do
    sign_in users(:mohamed_user)
    get root_url
    assert_redirected_to dashboard_path
  end

  test "logged in company should be redirected to dashboard from root" do
    sign_in users(:company_user)
    get root_url
    assert_redirected_to dashboard_path
  end
end
