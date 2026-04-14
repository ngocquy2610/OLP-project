class CartsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @cart = current_user.cart
    @cart_items = @cart.cart_items.includes(:course)
    @total_quantity = @cart_items.count
    
    @subtotal = @cart_items.sum { |item| item.course.price.to_i }
    @selected_ids = session[:selected_items] || []
    
    @discount = 0
    if session[:voucher_id]
      @voucher = Voucher.find_by(id: session[:voucher_id])
      
      if @voucher&.usable?
        @discount = (@subtotal * @voucher.discount_percent / 100.0).round
      else
        session[:voucher_id] = nil 
        @voucher = nil
      end
    end

    $total = @subtotal - @discount
  end

  def apply_voucher
    session[:selected_items] = params[:selected_items] if params[:selected_items].present?

    voucher = Voucher.find_by(code: params[:code].to_s.upcase)

    if voucher&.usable?
      session[:voucher_id] = voucher.id
      redirect_to cart_path, notice: "Áp dụng mã giảm giá thành công!"
    else
      redirect_to cart_path, alert: "Mã giảm giá không hợp lệ, đã hết hạn hoặc hết lượt dùng."
    end
  end

  def validate_voucher
    selected_ids = params[:selected_items]
    if selected_ids.blank?
      render json: { allowed: false, message: "Vui lòng chọn sản phẩm" }, status: :unprocessable_entity
      return
    end

    items = current_user.cart.cart_items.where(id: selected_ids)
    subtotal = items.map { |item| item.course.price.to_i }.sum

    code = params[:code].to_s.upcase
    voucher = Voucher.find_by(code: code)
    unless voucher&.usable?
      render json: { allowed: false, message: "Mã giảm giá không hợp lệ hoặc đã hết hạn" }, status: :unprocessable_entity
      return
    end

    computed = (subtotal * voucher.discount_percent.to_f / 100.0).round(0)
    min_price = (voucher.active_price || 20_000).to_i
    max_allowed_discount = [subtotal - min_price, 0].max

    if computed <= max_allowed_discount
      render json: { allowed: true }
    else
      render json: { allowed: false, message: "Tổng đã chọn quá nhỏ, sau khi áp dụng mã tối thiểu là #{min_price} VNĐ" }, status: :unprocessable_entity
    end
  end

  def remove_voucher
    session[:voucher_id] = nil
    redirect_to cart_path, notice: "Đã gỡ mã giảm giá."
  end

  def checkout
    selected_ids = params[:selected_items].presence || session.delete(:selected_items)

    if selected_ids.blank?
      redirect_to cart_path, alert: "Vui lòng chọn sản phẩm"
      return
    end

    items = current_user.cart.cart_items.where(id: selected_ids)
    items = items.reject { |i| i.course.user_id == current_user.id }

    if items.empty?
      redirect_to cart_path, alert: "Không có khóa học hợp lệ để thanh toán"
      return
    end

    subtotal = items.map { |item| item.course.price.to_i }.sum
    discount = 0
    voucher = nil
    
    
    if session[:voucher_id]
      voucher = Voucher.find_by(id: session[:voucher_id])
      if subtotal > voucher.active_price.to_i && voucher.usable?
        discount = (subtotal * voucher.discount_percent.to_f / 100.0).round(0)
        voucher.increment!(:used_count)
        session[:voucher_id] = nil
      else
        session[:voucher_id] = nil
        voucher = nil
      end
    end

    final_total = subtotal - discount

    order_attrs = {
      status: "pending",
      total: final_total,
      discount: discount
    }
    # binding.pry
    order_attrs[:voucher_id] = voucher.id if voucher.present?

    order = current_user.orders.create!(order_attrs)

    items.each do |item|
      order.order_items.create!(
        course: item.course,
        price: item.course.price
      )
    end

    redirect_to order_path(order)
  end
end
