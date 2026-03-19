# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # 1. Tích hợp Pundit để sử dụng authorize và policy trong Controller/View
  include Pundit::Authorization

  # 2. Xử lý lỗi khi User truy cập vào trang không có quyền (ví dụ Student vào trang của Teacher)
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Cấu hình Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home
    @featured_courses = Course.order(created_at: :asc).limit(3)
    puts "DEBUG: Found #{@featured_courses.count} courses"
    render "layouts/home"
  end

  protected

  def configure_permitted_parameters
    # Cho phép các trường mới khi đăng ký
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :fullname, :phone, :address, :role ])

    # Cho phép các trường mới khi cập nhật tài khoản
    devise_parameter_sanitizer.permit(:account_update, keys: [ :fullname, :phone, :address, :role ])
  end

  private

  # 3. Hàm xử lý khi bị từ chối quyền truy cập
  def user_not_authorized
    flash[:alert] = "Bạn không có quyền thực hiện hành động này."
    # Quay lại trang trước đó hoặc về trang chủ nếu không có trang trước
    redirect_to(request.referrer || root_path)
  end
end
