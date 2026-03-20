class CartsController < ApplicationController
  before_action :authenticate_user!
  def show
    @cart = current_user.cart
    @total_quantity = @cart.cart_items.count
  end

  def checkout
    selected_ids = params[:selected_items]

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

    order = current_user.orders.create!(
      status: "pending",
      total: items.map { |item| item.course.price.to_i }.sum
    )

    items.each do |item|
      order.order_items.create!(
        course: item.course,
        price: item.course.price
      )
    end

    redirect_to order_path(order)
  end
end
