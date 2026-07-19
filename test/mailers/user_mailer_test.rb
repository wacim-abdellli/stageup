# frozen_string_literal: true

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  def setup
    @student_user = users(:mohamed_user)
    @company_user = users(:company_user)
    @submission   = submissions(:accepted)
    @offer        = @submission.offer
    @agreement    = internship_agreements(:executed)
    @coord_user   = users(:university_user)
    @uni_profile  = university_profiles(:ahmed)
    @comp_profile = company_profiles(:one)
  end

  test "application_received_email renders correctly" do
    mail = UserMailer.application_received_email(@company_user, @submission)
    assert_equal "New Application Received – #{@offer.title}", mail.subject
    assert_equal [ @submission.offer.company_profile.user.email ], mail.to
    assert_match @offer.title, mail.body.encoded
  end

  test "application_status_updated_email renders without crashing" do
    mail = UserMailer.application_status_updated_email(@student_user, @submission)
    assert_equal [ @student_user.email ], mail.to
    assert_match @offer.title, mail.body.encoded
    assert_match @submission.offer.company_profile.name, mail.body.encoded
  end

  test "agreement_signature_requested_email renders correctly" do
    mail = UserMailer.agreement_signature_requested_email(@student_user, @agreement)
    assert_equal [ @student_user.email ], mail.to
    assert_match @offer.title, mail.body.encoded
  end

  test "agreement_declined_email renders correctly" do
    mail = UserMailer.agreement_declined_email(@student_user, @agreement)
    assert_equal [ @student_user.email ], mail.to
  end

  test "coordinator_approved_email renders correctly" do
    mail = UserMailer.coordinator_approved_email(@coord_user, @uni_profile)
    assert_equal "Your Coordinator Account Has Been Approved", mail.subject
    assert_equal [ @coord_user.email ], mail.to
    assert_match @uni_profile.admin_name, mail.body.encoded
  end

  test "company_verified_email renders correctly" do
    mail = UserMailer.company_verified_email(@company_user, @comp_profile)
    assert_equal "Your Company Account Has Been Verified", mail.subject
    assert_equal [ @company_user.email ], mail.to
    assert_match @comp_profile.name, mail.body.encoded
  end
end
