# frozen_string_literal: true

class Rack::Attack
  ### Safelist local/loopback IPs for development and testing ###
  safelist("allow from localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1" || req.ip == "0.0.0.0"
  end

  ### Throttle signup attempts by IP ###
  throttle("signup/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path.start_with?("/signup") && req.post?
  end

  ### Throttle login attempts by IP ###
  throttle("login/ip", limit: 10, period: 20.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  ### Throttle login attempts by email ###
  throttle("login/email", limit: 5, period: 20.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.gsub(/\s+/, "")
    end
  end

  ### Throttle password reset requests ###
  throttle("password_reset/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  ### Throttle registration attempts by IP ###
  throttle("signup/student/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/signup/student" && req.post?
  end
  throttle("signup/company/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/signup/company" && req.post?
  end
  throttle("signup/university/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path == "/signup/university" && req.post?
  end

  ### Global rate limit per IP for all authenticated requests ###
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets", "/packs")
  end

  ### Throttle submission verification endpoint ###
  throttle("verify_submission/ip", limit: 10, period: 10.minutes) do |req|
    req.ip if req.path.match?(%r{/submissions/\d+/update}) && req.patch?
  end

  ### Return 429 with a JSON body for throttled requests ###
  self.throttled_responder = lambda do |env|
    match_data = env.respond_to?(:[]) ? env["rack.attack.match_data"] : nil
    retry_after = (match_data || {})[:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Too many requests. Please try again later." }.to_json]
    ]
  end
end
