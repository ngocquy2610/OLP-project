class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home
    render "layouts/home"
  end

  protected

  def configure_permitted_parameters
    # Permit the new fields for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :fullname, :phone, :address, :role ])

    # Permit them for account editing as well
    devise_parameter_sanitizer.permit(:account_update, keys: [ :fullname, :phone, :address, :role ])
  end
end
