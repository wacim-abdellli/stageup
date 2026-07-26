require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guest user should get index landing page" do
    get root_url
    assert_response :success
    assert_select "h1", /Nobody pays a price for ghosting/
  end

  test "logged in student can view the landing page" do
    sign_in users(:mohamed_user)
    get root_url
    assert_response :success
  end

  test "logged in company can view the landing page" do
    sign_in users(:company_user)
    get root_url
    assert_response :success
  end
end
