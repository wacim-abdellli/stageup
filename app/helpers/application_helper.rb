module ApplicationHelper
  def notification_icon(action)
    case action
    when "application_accepted"       then "check-circle"
    when "application_rejected"       then "x-circle"
    when "application_received"       then "inbox"
    when "application_ghosted"        then "clock"
    when "internship_abandoned"       then "log-out"
    when "internship_cancelled"       then "slash"
    when "internship_completed"       then "award"
    when "internship_auto_completed"  then "check-circle-2"
    when "mission_expired"            then "timer-off"
    when "agreement_signature_requested" then "file-signature"
    when "agreement_declined"         then "file-x"
    when "company_verified"           then "shield-check"
    when "coordinator_approved"       then "user-check"
    else "bell"
    end
  end

  def action_icon_color(action)
    case action
    when /accepted|completed|verified|approved|signature/ then "icon-green"
    when /rejected|declined|abandoned|cancelled|expired/ then "icon-red"
    when /received|requested/ then "icon-blue"
    when /ghosted|auto/ then "icon-amber"
    else "icon-muted"
    end
  end
end
