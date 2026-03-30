class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@yourdomain.com"
  layout "mailer"
end
