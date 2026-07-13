# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEVISE_MAILER_SENDER", "StageUp <noreply@stageup.tn>"),
          reply_to: ENV.fetch("SUPPORT_EMAIL", "support@stageup.tn")
  layout "mailer"
end
