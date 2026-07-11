class ResolveExpiredSubmissionsJob < ApplicationJob
  queue_as :default

  def perform
    Submission.where(status: "started").where("created_at < ?", 48.hours.ago).find_each do |sub|
      ActiveRecord::Base.transaction do
        sub.update_columns(status: "expired", updated_at: Time.current)

        student = sub.student_profile
        prior_expired_count = student.commitment_events.where(event_type: "student_mission_expired").count

        if prior_expired_count == 0
          delta = 0.0
          desc = "Proof mission for '#{sub.offer.title}' expired. First-time warning (no penalty)."
        else
          delta = -10.0
          desc = "Proof mission for '#{sub.offer.title}' expired after 48 hours."
        end

        student.commitment_events.create!(
          event_type: "student_mission_expired",
          score_delta: delta,
          description: desc
        )

        student.recalculate_commitment_score!
      end
    end

    Submission.where(status: "accepted").where("first_completion_confirmed_at < ?", 7.days.ago).find_each do |sub|
      ActiveRecord::Base.transaction do
        sub.update_columns(
          status: "completed",
          student_confirmed_completed: true,
          company_confirmed_completed: true,
          responded_at: Time.current
        )

        sub.student_profile.commitment_events.create!(
          event_type: "student_completed_internship",
          score_delta: 15.0,
          description: "Internship completed for '#{sub.offer.title}' (auto-approved after 7 days)."
        )

        sub.student_profile.recalculate_commitment_score!
      end
    end
  end
end
