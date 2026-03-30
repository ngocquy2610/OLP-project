class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    super
  end
end