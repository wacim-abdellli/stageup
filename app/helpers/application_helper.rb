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

  def render_notification_icon_svg(action)
    case action.to_s
    when /agreement|signature/
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M10 13l2 2 4-4"/></svg>'.html_safe
    when /coordinator|approved|verified/
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>'.html_safe
    when /accepted|completed/
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>'.html_safe
    when /rejected|declined|cancelled/
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>'.html_safe
    else
      '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>'.html_safe
    end
  end
end
