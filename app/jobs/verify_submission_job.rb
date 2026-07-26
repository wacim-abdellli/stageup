# frozen_string_literal: true

require "open3"
require "timeout"

class VerifySubmissionJob < ApplicationJob
  queue_as :default

  ALLOWED_GIT_HOSTS = %w[github.com gitlab.com bitbucket.org].freeze

  def perform(submission)
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{submission.id}")
    submission.update_columns(auto_verification_status: "checking")

    begin
      FileUtils.mkdir_p(temp_folder)

      url = submission.github_link.to_s
      return unless validate_url!(url, submission)

      result = clone_repository(url, temp_folder, submission)
      return unless result

      return unless check_repository_size(temp_folder, submission)

      passed = verify_project_files(temp_folder, submission)
      finalize_submission(submission, passed)
    ensure
      FileUtils.rm_rf(temp_folder)
    end
  end

  private

  def clone_repository(url, temp_folder, submission)
    stdout, stderr, status = Timeout.timeout(30) do
      env = {
        "GIT_SSH_COMMAND" => "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null",
        "GIT_TERMINAL_PROMPT" => "0",
        "GIT_ASKPASS" => "echo",
        "GIT_CONFIG_NOSYSTEM" => "1",
        "HOME" => "/dev/null"
      }
      Open3.capture3(env, "git", "clone", "--depth", "1", "--no-tags",
                     "--config", "credential.helper=", "--", url, temp_folder.to_s)
    end

    unless status.success?
      submission.update_columns(
        auto_verification_status: "failed",
        auto_verification_log: "Git clone failed: #{(stdout + stderr).strip.truncate(500)}"
      )
      return nil
    end

    true
  rescue Timeout::Error
    submission.update_columns(
      auto_verification_status: "failed",
      auto_verification_log: "Git clone timed out after 30 seconds."
    )
    nil
  end

  def check_repository_size(temp_folder, submission)
    stdout, _, _ = Open3.capture3("du", "-sm", temp_folder.to_s)
    dir_size_mb = stdout.split.first.to_i rescue 0

    if dir_size_mb > 100
      submission.update_columns(
        auto_verification_status: "failed",
        auto_verification_log: "Repository too large (#{dir_size_mb}MB). Maximum allowed size is 100MB."
      )
      return false
    end

    true
  end

  def verify_project_files(temp_folder, submission)
    project_files = %w[Gemfile package.json README.md .git]
    found = project_files.any? { |f| File.exist?(temp_folder.join(f)) }

    if found
      submission.update_columns(
        auto_verification_status: "passed",
        auto_verification_log: "Repository successfully cloned and verified."
      )
    else
      submission.update_columns(
        auto_verification_status: "failed",
        auto_verification_log: "Repository cloned, but failed validation: missing README.md or configuration files."
      )
    end

    found
  end

  def finalize_submission(submission, passed)
    submission.reload
    return unless %w[passed failed].include?(submission.auto_verification_status)
    return unless passed

    company_user = submission.offer.company_profile.user
    Notification.trigger(
      recipient: company_user,
      action: "application_received",
      message: "#{submission.student_profile.first_name}'s proof mission for #{submission.offer.title} has been verified.",
      notifiable: submission
    )
    UserMailer.application_received_email(company_user, submission).deliver_later
  end

  def validate_url!(url, submission)
    begin
      uri = URI.parse(url)
      unless uri.scheme == "https" && ALLOWED_GIT_HOSTS.include?(uri.host&.downcase)
        submission.update_columns(
          auto_verification_status: "failed",
          auto_verification_log: "Only HTTPS URLs from GitHub, GitLab, or Bitbucket are accepted. Got: #{uri.host}"
        )
        return false
      end
    rescue URI::InvalidURIError
      submission.update_columns(
        auto_verification_status: "failed",
        auto_verification_log: "Invalid URL format."
      )
      return false
    end
    true
  end
end
