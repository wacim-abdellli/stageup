require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @offer = offers(:one)
  end

  test "guest user should get index of active offers" do
    get offers_url
    assert_response :success
  end

  test "guest user should get show of offer" do
    get offer_url(@offer)
    assert_response :success
  end
end
