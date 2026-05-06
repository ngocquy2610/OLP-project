# frozen_string_literal: true

Devise::JWT.configure do |config|
  config.secret = Rails.application.config.secret_key_base
  config.dispatch_requests = [
    ['POST', %r{^/api/users/sign_in$}],
    ['POST', %r{^/users/sign_in$}]
  ]
  config.revocation_requests = [
    ['DELETE', %r{^/api/users/sign_out$}],
    ['DELETE', %r{^/users/sign_out$}]
  ]
  config.expiration_time = 1.day.to_i
end
