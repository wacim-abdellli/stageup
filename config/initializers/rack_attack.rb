# frozen_string_literal: true

class Rack::Attack
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

  ### Return 429 with a JSON body for throttled requests ###
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
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
