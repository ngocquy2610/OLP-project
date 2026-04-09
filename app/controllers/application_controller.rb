class ApplicationController < ActionController::Base
  before_action :set_cart_quantity
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale

  def home
    @featured_courses = Course.order(created_at: :asc).limit(3)
    puts "DEBUG: Found #{@featured_courses.count} courses"
    render "layouts/home"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :fullname, :phone, :address, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :fullname, :phone, :address, :role ])
  end

  private

  def user_not_authorized
    flash[:alert] = I18n.t('flash.not_authorized')
    redirect_to(request.referrer || root_path)
  end

  def set_cart_quantity
    return unless user_signed_in?
    @total_quantity = current_user.cart&.cart_items&.count || 0
  end

  def switch_locale(&action)
    if params[:locale].present?
      session[:locale] = params[:locale]
    end

    locale = session[:locale] || I18n.default_locale
    
    I18n.with_locale(locale, &action)
  end
end
