# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def application_received_email(user, submission)
    return if user.nil? || user.email.blank?
    @user = user
    @submission = submission
    @offer = submission.offer
    @company = submission.offer.company_profile
    mail(to: @company.user.email, subject: t('user_mailer.application_received.subject', offer_title: @offer.title))
  end

  def application_status_updated_email(user, submission)
    return if user.nil? || user.email.blank?
    @user = user
    @submission = submission
    @offer = submission.offer
    @company = submission.offer.company_profile
    @status = submission.status
    mail(to: @user.email, subject: t('user_mailer.application_status_updated.subject', status: @status.humanize, offer_title: @offer.title))
  end

  def agreement_signature_requested_email(user, agreement)
    return if user.nil? || user.email.blank?
    @user = user
    @agreement = agreement
    @submission = agreement.submission
    @offer = @submission.offer
    mail(to: @user.email, subject: t('user_mailer.agreement_signature_requested.subject', offer_title: @offer.title))
  end

  def agreement_declined_email(user, agreement)
    return if user.nil? || user.email.blank?
    @user = user
    @agreement = agreement
    @submission = agreement.submission
    @offer = @submission.offer
    @reason = agreement.rejection_reason
    mail(to: @user.email, subject: t('user_mailer.agreement_declined.subject', offer_title: @offer.title))
  end

  def coordinator_approved_email(user, profile)
    return if user.nil? || user.email.blank?
    @user = user
    @profile = profile
    mail(to: @user.email, subject: t('user_mailer.coordinator_approved.subject'))
  end

  def company_verified_email(user, profile)
    return if user.nil? || user.email.blank?
    @user = user
    @profile = profile
    mail(to: @user.email, subject: t('user_mailer.company_verified.subject'))
  end
end
