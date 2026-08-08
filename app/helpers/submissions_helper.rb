module SubmissionsHelper
  def submission_milestones(sub)
    milestones = []

    milestones << {
      label: I18n.t("submissions.milestones.applied"),
      complete: sub.submitted_at.present?,
      timestamp: sub.submitted_at
    }

    milestones << {
      label: I18n.t("submissions.milestones.checked"),
      complete: sub.offer.mission.nil? || sub.auto_verification_status == "passed" || %w[accepted completed].include?(sub.status),
      timestamp: sub.submitted_at
    }

    milestones << {
      label: I18n.t("submissions.milestones.accepted"),
      complete: %w[accepted completed].include?(sub.status),
      timestamp: sub.responded_at
    }

    agreement = sub.internship_agreement
    signed_ts = nil
    if agreement
      signed_ts = agreement.student_signed_at || agreement.company_signed_at || agreement.university_signed_at
    end
    milestones << {
      label: I18n.t("submissions.milestones.signed"),
      complete: agreement&.status == "fully_executed",
      timestamp: signed_ts
    }

    completed_ts = sub.first_completion_confirmed_at || sub.responded_at
    milestones << {
      label: I18n.t("submissions.milestones.done"),
      complete: sub.status == "completed",
      timestamp: completed_ts
    }

    milestones
  end
end
