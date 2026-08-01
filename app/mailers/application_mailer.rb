# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV["DEVISE_MAILER_SENDER"].presence || ENV["SMTP_USERNAME"].presence || "StageUp <noreply@stageup.tn>",
          reply_to: ENV.fetch("SUPPORT_EMAIL", "support@stageup.tn")
  layout "mailer"
end
