require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @offer = offers(:one)
    @company_user = users(:company_user)
    @student_user = users(:mohamed_user)
  end

  test "guest user should get index of active offers" do
    get offers_url
    assert_response :success
  end

  test "guest user should get show of offer" do
    get offer_url(@offer)
    assert_response :success
  end

  test "guest user cannot access edit" do
    get edit_offer_url(@offer)
    assert_redirected_to new_user_session_path
  end

  test "company user can access edit on own offer" do
    sign_in @company_user
    get edit_offer_url(@offer)
    assert_response :success
  end

  test "non-company user cannot access edit" do
    sign_in @student_user
    get edit_offer_url(@offer)
    assert_redirected_to dashboard_path
    assert_equal "Only verified recruiters can manage internship offers.", flash[:alert]
  end

  test "unverified company cannot access new offer form" do
    sign_in users(:company_user_two)
    get new_offer_url
    assert_redirected_to dashboard_path
    assert_equal "Your account is pending verification by StageUp administrators. You cannot post internship offers yet.", flash[:alert]
  end

  test "unverified company cannot create offer" do
    sign_in users(:company_user_two)
    post offers_url, params: { offer: { title: "Test", description: "Test", stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite" } }
    assert_redirected_to dashboard_path
    assert_equal "Your account is pending verification by StageUp administrators. You cannot post internship offers yet.", flash[:alert]
  end

  test "company user can update own offer" do
    sign_in @company_user
    patch offer_url(@offer), params: { offer: { title: "Updated Title" } }
    assert_redirected_to dashboard_path
    @offer.reload
    assert_equal "Updated Title", @offer.title
  end

  test "company user can destroy draft offer (permanent delete)" do
    sign_in @company_user
    draft_offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Draft Offer",
      description: "Not ready",
      stage_type: "PFE",
      spots: 1,
      location: "Sfax",
      work_mode: "onsite",
      status: "draft"
    )

    assert_difference("Offer.count", -1) do
      delete offer_url(draft_offer)
    end
    assert_redirected_to dashboard_path
    assert_equal "Offer was permanently deleted.", flash[:notice]
  end

  test "non-owner cannot view draft offer" do
    sign_in @student_user

    draft = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Secret Draft",
      description: "Not ready",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "draft"
    )

    get offer_url(draft)
    assert_redirected_to dashboard_path
    assert_equal "Offer not found or not yet active.", flash[:alert]
  end

  test "owner can view draft offer" do
    sign_in @company_user

    draft = Offer.create!(
      company_profile: company_profiles(:one),
      title: "My Draft",
      description: "Not ready",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "draft"
    )

    get offer_url(draft)
    assert_response :success
  end

  test "destroy on active offer archives instead of deleting" do
    sign_in @company_user

    assert_no_difference("Offer.count") do
      delete offer_url(@offer)
    end
    assert_redirected_to dashboard_path
    @offer.reload
    assert_equal "archived", @offer.status
  end
end
