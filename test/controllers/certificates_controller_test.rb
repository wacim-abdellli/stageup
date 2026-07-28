# frozen_string_literal: true

require "test_helper"

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @executed_agreement = internship_agreements(:executed)
    @pending_agreement = internship_agreements(:pending_agreement)
  end

  test "should verify valid token for fully executed agreement" do
    get verify_certificate_url(token: @executed_agreement.verification_token)
    assert_response :success
    assert_select ".cert-title", text: I18n.t("certificates.verify.title")
    assert_select ".cert-student-name", text: /#{@executed_agreement.submission.student_profile.first_name}/
  end

  test "should redirect to root for invalid token" do
    get verify_certificate_url(token: "non_existent_token_123")
    assert_redirected_to root_path
    assert_equal "The requested resource was not found.", flash[:alert]
  end

  test "should redirect to root for non-fully_executed agreement" do
    get verify_certificate_url(token: @pending_agreement.verification_token)
    assert_redirected_to root_path
    assert_equal "This certificate has not been fully executed yet.", flash[:alert]
  end
end
