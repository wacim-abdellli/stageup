require "open3"
require "ostruct"

class VerifySubmissionJob < ApplicationJob
  queue_as :default

  def perform(submission)
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{submission.id}")
    submission.update!(auto_verification_status: "checking")

    begin
      FileUtils.mkdir_p(temp_folder)

      url = submission.github_link.to_s
      unless url.match?(/\Ahttps?:\/\/[^\s]+\z/)
        submission.update!(
          auto_verification_status: "failed",
          auto_verification_log: "Invalid URL format."
        )
        return
      end

      stdout, stderr, status = Open3.capture3("git", "clone", "--depth", "1", "--", url, temp_folder.to_s)

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
      if submission.auto_verification_status != "pending"
        submission.update!(status: "submitted", submitted_at: Time.current)
      end
    end
  end
end
