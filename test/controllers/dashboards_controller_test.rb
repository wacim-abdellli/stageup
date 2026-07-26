require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "approved university coordinator can load dashboard and sees stats" do
    sign_in users(:university_user)
    get dashboard_url
    assert_response :success
    assert_match "Prof. Ahmed Mansour", @response.body
    assert_select ".rep-stat-label", text: "Associated Students"
    assert_select "strong", text: "1"
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

  test "company can see under_review submissions in dashboard" do
    company_user = users(:company_user)
    company_profile = company_profiles(:one)
    new_offer = Offer.create!(
      company_profile: company_profile,
      title: "Under Review Test Offer",
      description: "Test",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )

    submission = Submission.create!(
      student_profile: student_profiles(:mohamed),
      offer: new_offer,
      status: "under_review",
      submitted_at: Time.current,
      github_link: "https://github.com/test/repo"
    )

    sign_in company_user
    get dashboard_url
    assert_response :success
    pending_subs = @controller.instance_variable_get(:@pending_submissions)
    assert_includes pending_subs, submission
  end
end
