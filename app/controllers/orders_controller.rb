class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
    @orders = @orders.includes(order_items: :course)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def invoice
    @order = current_user.orders.includes(order_items: :course).find(params[:id])

    respond_to do |format|
      format.html 
      
      format.pdf do
        render pdf: "Invoice_#{@order.id}",
               template: "orders/pdf_invoice",
               formats: [:html],
               layout: false,
               margin: { top: 15, bottom: 15, left: 15, right: 15 }
      end
    end
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

  def checkout
    order = current_user.orders.find(params[:id])

    subtotal_amount = order.order_items.sum(:price).to_i
    if subtotal_amount == 0
      order.update(status: "paid")

      order.order_items.each do |item|
        current_user.enrollments.find_or_create_by!(course: item.course)
      end

      order.order_items.includes(course: :user).group_by { |oi| oi.course.user }.each do |teacher, items|
        PaymentMailer.teacher_notification_email(teacher, current_user, order).deliver_later
      end

      PaymentMailer.student_receipt_email(current_user, order).deliver_later

      if current_user.cart.present?
        purchased_course_ids = order.order_items.pluck(:course_id)
        current_user.cart.cart_items.where(course_id: purchased_course_ids).destroy_all
      end

      redirect_to courses_path, notice: "Payment successful! You can now access your courses."
      return
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: order.order_items.map do |item|
        {
          price_data: {
            currency: "vnd",
            product_data: {
              name: item.course.name
            },
            unit_amount: order.total.to_i
          },
          quantity: 1
        }
      end,
      mode: "payment",
      success_url: success_order_url(order),
      cancel_url: cancel_order_url(order)
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    order = current_user.orders.find(params[:id])
    order.update(status: "paid")

    order.order_items.each do |item|
      course = item.course
      amount_paid = item.price.to_i

      current_user.enrollments.find_or_create_by!(course: course)
    end

    # notify each teacher once with the courses sold to them
    order.order_items.includes(course: :user).group_by { |oi| oi.course.user }.each do |teacher, items|
      PaymentMailer.teacher_notification_email(teacher, current_user, order).deliver_later
    end

    # send a single receipt email for the whole order
    PaymentMailer.student_receipt_email(current_user, order).deliver_later

    if current_user.cart.present?
      purchased_course_ids = order.order_items.pluck(:course_id)
      
      current_user.cart.cart_items.where(course_id: purchased_course_ids).destroy_all
    end

    redirect_to courses_path, notice: "Payment successful! You can now access your courses."
  end

  def cancel
    redirect_to cart_path, alert: "Payment canceled"
  end
end
