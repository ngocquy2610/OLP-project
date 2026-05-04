class ApplicationController < ActionController::Base
  include LocaleSwitchable
  include TurboFrameFlashable

  before_action :set_cart_quantity
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  def home
    top_course_ids = Enrollment.group(:course_id)
                           .order(Arel.sql('COUNT(course_id) DESC'))
                           .limit(3)
                           .count
    @featured_courses = Course.where(id: top_course_ids.keys).order(created_at: :asc).limit(3)
    puts "DEBUG: Found #{@featured_courses.count} courses"
    render "layouts/home"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :fullname, :phone, :address, :role, :bank_name, :bank_account_number, :bank_account_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :fullname, :phone, :address, :role, :bank_name, :bank_account_number, :bank_account_name, :stripe_account_id])
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
end
