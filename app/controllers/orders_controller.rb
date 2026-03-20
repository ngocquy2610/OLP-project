class OrdersController < ApplicationController
  before_action :authenticate_user!

  def show
    @order = current_user.orders.find(params[:id])
  end

  def pay
    @order = current_user.orders.find(params[:id])

    @order.update(status: "paid")

    @order.order_items.each do |item|
      Enrollment.find_or_create_by!(
        user: current_user,
        course: item.course
      )
    end

    current_user.cart.cart_items
      .where(course_id: @order.order_items.pluck(:course_id))
      .destroy_all

    redirect_to courses_path, notice: "Bạn đã sở hữu khóa học!"
  end
end
