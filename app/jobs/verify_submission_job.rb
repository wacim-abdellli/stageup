require "open3"
require "ostruct"
require "timeout"

class VerifySubmissionJob < ApplicationJob
  queue_as :default

  ALLOWED_GIT_HOSTS = %w[github.com gitlab.com bitbucket.org].freeze

  def perform(submission)
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{submission.id}")
    submission.update!(auto_verification_status: "checking")

    begin
      FileUtils.mkdir_p(temp_folder)

      url = submission.github_link.to_s
      unless validate_url!(url, submission)
        return
      end

      begin
        stdout, stderr, status = Timeout.timeout(30) do
          Open3.capture3("git", "clone", "--depth", "1", "--", url, temp_folder.to_s)
        end
      rescue Timeout::Error
        submission.update!(
          auto_verification_status: "failed",
          auto_verification_log: "Git clone timed out after 30 seconds."
        )
        return
      end

      if !status.success?
        submission.update!(
          auto_verification_status: "failed",
          auto_verification_log: "Git clone failed: #{(stdout + stderr).strip.truncate(500)}"
        )
        return
      end

      project_files = %w[Gemfile package.json README.md .git]
      found = project_files.any? { |f| File.exist?(temp_folder.join(f)) }

      if found
        submission.update!(
          auto_verification_status: "passed",
          auto_verification_log: "Repository successfully cloned and verified."
        )
      else
        submission.update!(
          auto_verification_status: "failed",
          auto_verification_log: "Repository cloned, but failed validation: missing README.md or configuration files."
        )
      end
    ensure
      FileUtils.rm_rf(temp_folder)
      if %w[passed failed].include?(submission.reload.auto_verification_status)
        submission.update!(status: "submitted", submitted_at: Time.current)
      end
    end
  end

  private

  def validate_url!(url, submission)
    begin
      uri = URI.parse(url)
      unless uri.scheme == "https" && ALLOWED_GIT_HOSTS.include?(uri.host&.downcase)
        submission.update!(
          auto_verification_status: "failed",
          auto_verification_log: "Only HTTPS URLs from GitHub, GitLab, or Bitbucket are accepted. Got: #{uri.host}"
        )
        return false
      end
    rescue URI::InvalidURIError
      submission.update!(
        auto_verification_status: "failed",
        auto_verification_log: "Invalid URL format."
      )
      return false
    end
    true
  end
end
