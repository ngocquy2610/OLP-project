class ApplicationController < ActionController::Base
  before_action :set_cart_quantity
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

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
    flash[:alert] = "Bạn không có quyền thực hiện hành động này."
    redirect_to(request.referrer || root_path)
  end

  def set_cart_quantity
    return unless user_signed_in?
    @total_quantity = current_user.cart&.cart_items&.count || 0
  end
end
