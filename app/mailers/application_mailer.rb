class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEVISE_MAILER_SENDER", "StageUp <noreply@stageup.tn>")
  layout "mailer"
end
