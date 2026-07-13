# frozen_string_literal: true

# Add HTTP security headers to all responses
Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Frame-Options"        => "DENY",
  "X-Content-Type-Options" => "nosniff",
  "X-XSS-Protection"       => "0",
  "Referrer-Policy"         => "strict-origin-when-cross-origin",
  "Permissions-Policy"      => "camera=(), microphone=(), geolocation=(), payment=()"
)
