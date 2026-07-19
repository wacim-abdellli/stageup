require "test_helper"
require "ostruct"

class VerifySubmissionJobTest < ActiveJob::TestCase
  self.use_transactional_tests = true
  parallelize(workers: 0)

  def stub_open3_success
    original = Open3.method(:capture3)
    Open3.define_singleton_method(:capture3) { |*_args| [ "", "", OpenStruct.new(success?: true) ] }
    yield
  ensure
    Open3.define_singleton_method(:capture3, original)
  end

  def stub_open3_failure(output = "fatal: repository not found")
    original = Open3.method(:capture3)
    status = OpenStruct.new(success?: false, exitstatus: 128)
    Open3.define_singleton_method(:capture3) { |*_args| [ "", output, status ] }
    yield
  ensure
    Open3.define_singleton_method(:capture3, original)
  end

  def create_test_submission
    offer = Offer.create!(
      company_profile: company_profiles(:one),
      title: "Job Test #{SecureRandom.hex(4)}",
      description: "For job verification tests",
      stage_type: "PFE", spots: 1, location: "Sfax", work_mode: "onsite", status: "active"
    )
    sub = Submission.create!(
      student_profile: student_profiles(:mohamed),
      offer: offer,
      status: "under_review",
      github_link: "https://github.com/test/repo"
    )
    sub.update_columns(auto_verification_status: "pending")
    sub
  end

  test "passes verification when repo has project files" do
    sub = create_test_submission
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{sub.id}")
    FileUtils.mkdir_p(temp_folder)
    File.write(temp_folder.join("README.md"), "# Test Repo")

    stub_open3_success do
      VerifySubmissionJob.perform_now(sub)
    end

    sub.reload
    assert_equal "passed", sub.auto_verification_status
    assert_equal "Repository successfully cloned and verified.", sub.auto_verification_log
    assert_equal "submitted", sub.status
    assert_not Dir.exist?(temp_folder)
  end

  test "fails verification when repo has no project files" do
    sub = create_test_submission
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{sub.id}")
    FileUtils.mkdir_p(temp_folder)

    stub_open3_success do
      VerifySubmissionJob.perform_now(sub)
    end

    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "missing README.md or configuration files"
    assert_equal "submitted", sub.status
    assert_not Dir.exist?(temp_folder)
  end

  test "fails verification when git clone fails" do
    sub = create_test_submission

    stub_open3_failure do
      VerifySubmissionJob.perform_now(sub)
    end

    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "Git clone failed"
    assert_equal "submitted", sub.status
  end

  test "cleans up temp folder in ensure block" do
    sub = create_test_submission
    temp_folder = Rails.root.join("tmp", "sandboxes", "submission_#{sub.id}")

    stub_open3_success do
      VerifySubmissionJob.perform_now(sub)
    end

    assert_not Dir.exist?(temp_folder)
  end

  test "rejects file:// URLs" do
    sub = create_test_submission
    sub.update_columns(github_link: "file:///etc/passwd")
    VerifySubmissionJob.perform_now(sub)
    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "Only HTTPS URLs"
  end

  test "rejects non-allowlisted hosts" do
    sub = create_test_submission
    sub.update_columns(github_link: "https://attacker.com/repo")
    VerifySubmissionJob.perform_now(sub)
    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "Only HTTPS URLs"
  end

  test "rejects git:// scheme" do
    sub = create_test_submission
    sub.update_columns(github_link: "git://github.com/repo")
    VerifySubmissionJob.perform_now(sub)
    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "Only HTTPS URLs"
  end

  test "rejects empty URL" do
    sub = create_test_submission
    sub.update_columns(github_link: "")
    VerifySubmissionJob.perform_now(sub)
    sub.reload
    assert_equal "failed", sub.auto_verification_status
    assert_includes sub.auto_verification_log, "Only HTTPS URLs"
  end
end
