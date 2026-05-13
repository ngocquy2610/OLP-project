class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
    @orders = @orders.includes(order_items: :course)
  end

  def show
    @order = current_user.orders.find_by(id: params[:id])
  end

  def invoice
    @order = current_user.orders.includes(order_items: :course).find_by(id: params[:id])

    respond_to do |format|
      format.html

      format.pdf do
        render pdf: "Invoice_#{@order.id}",
               template: "orders/pdf_invoice",
               formats: [ :html ],
               layout: false,
               margin: { top: 15, bottom: 15, left: 15, right: 15 }
      end
    end
  end

  def pay
    @order = current_user.orders.find_by(id: params[:id])

    # Đảm bảo không xử lý lại nếu đã thanh toán
    unless @order.status == "paid"
      @order.update(status: "paid")

      @order.order_items.each do |item|
        Enrollment.find_or_create_by!(
          user: current_user,
          course: item.course
        )

        # CỘNG TIỀN CHO GIÁO VIÊN NẾU THANH TOÁN QUA HÀM NÀY
        teacher = item.course.user
        teacher_share = (item.price.to_i * 0.90).to_i
        teacher.increment!(:balance, teacher_share) if teacher_share > 0
      end

      current_user.cart.cart_items
        .where(course_id: @order.order_items.pluck(:course_id))
        .destroy_all
    end

    redirect_to courses_path, notice: I18n.t("messages.orders.already_owned")
  end

  def checkout
    order = current_user.orders.find_by(id: params[:id])
    @usd_rate = (JSON.parse(File.read(Rails.root.join("exchange_rate.json")))["rate"] rescue nil)
    subtotal_amount = order.order_items.sum(:price).to_i
    subtotal_amount_in_usd = (subtotal_amount * @usd_rate * 100).to_i

    # Xử lý đơn hàng miễn phí (Giá = 0)
    if subtotal_amount == 0
      unless order.status == "paid"
        order.update(status: "paid")

        order.order_items.each do |item|
          current_user.enrollments.find_or_create_by!(course: item.course)
          # Tiền = 0 nên không cần cộng ví cho giáo viên ở đây
        end

        order.order_items.includes(course: :user).group_by { |oi| oi.course.user }.each do |teacher, items|
          PaymentMailer.teacher_notification_email(teacher, current_user, order).deliver_later
        end

        PaymentMailer.student_receipt_email(current_user, order).deliver_later

        if current_user.cart.present?
          purchased_course_ids = order.order_items.pluck(:course_id)
          current_user.cart.cart_items.where(course_id: purchased_course_ids).destroy_all
        end
      end

      redirect_to courses_path, notice: I18n.t("messages.orders.payment_success")
      return
    end

    # Build Stripe line items using each item's original price
    stripe_line_items = order.order_items.map do |item|
      {
        price_data: {
          currency: "usd",
          product_data: { name: item.course.name },
          unit_amount: (item.price.to_i * @usd_rate * 100).to_i
        },
        quantity: 1
      }
    end

    session_params = {
      payment_method_types: [ "card" ],
      line_items: stripe_line_items,
      mode: "payment",
      success_url: success_order_url(order),
      cancel_url: cancel_order_url(order)
    }

    if order.discount.to_i > 0
      coupon = Stripe::Coupon.create(
        amount_off: (order.discount.to_i * @usd_rate * 100).to_i,
        currency: "usd",
        duration: "once"
      )

      session_params[:discounts] = [ { coupon: coupon.id } ]
    end

    session = Stripe::Checkout::Session.create(session_params)

    redirect_to session.url, allow_other_host: true
  end

  def gmo_checkout
    @order = current_user.orders.find_by(id: params[:id])
    # Không redirect gì ở đây cả, Rails sẽ tự động tìm file view gmo_checkout.html.erb để hiển thị
  end

  def success
    order = current_user.orders.find_by(id: params[:id])

    unless order.status == "paid"
      order.update(status: "paid")

      order.order_items.each do |item|
        course = item.course

        current_user.enrollments.find_or_create_by!(course: course)

        teacher = course.user

        teacher_share = (item.price.to_i * 0.90).to_i
        teacher.increment!(:balance, teacher_share) if teacher_share > 0
      end

      order.order_items.includes(course: :user).group_by { |oi| oi.course.user }.each do |teacher, items|
        PaymentMailer.teacher_notification_email(teacher, current_user, order).deliver_later
      end

      PaymentMailer.student_receipt_email(current_user, order).deliver_later

      if current_user.cart.present?
        purchased_course_ids = order.order_items.pluck(:course_id)
        current_user.cart.cart_items.where(course_id: purchased_course_ids).destroy_all
      end
    end

    redirect_to courses_path, notice: I18n.t("messages.orders.payment_success")
  end

  def cancel
    redirect_to cart_path, alert: I18n.t("messages.orders.payment_canceled")
  end

  # Handle GMO token submission
  def charge_gmo
    order = current_user.orders.find_by(id: params[:id])

    if order.status == "paid"
      redirect_to courses_path, notice: I18n.t("messages.orders.already_paid") and return
    end

    # Expect a frontend token. Do NOT accept raw card numbers from the server.
    token = params[:Token].presence || params[:gmo_token].presence

    if token.blank?
      # If no token, reject and ask user to retry with tokenization enabled
      redirect_to order_path(order), alert: I18n.t("messages.orders.missing_token") and return
    end

    # Pass token to service (service will use Token instead of raw card fields)
    service = GmoPaymentService.new(order, token: token)
    result = service.charge_card

    if result[:success]
      # CHỈ KHI GMO TRẢ VỀ SUCCESS THÌ MỚI ĐƯỢC PHÉP CỘNG TIỀN VÀ GIAO KHÓA HỌC
      order.update(status: "paid")

      order.order_items.each do |item|
        current_user.enrollments.find_or_create_by!(course: item.course)

        teacher = item.course.user
        teacher_share = (item.price.to_i * 0.90).to_i
        teacher.increment!(:balance, teacher_share) if teacher_share > 0
      end

      # Gửi email thông báo
      order.order_items.includes(course: :user).group_by { |oi| oi.course.user }.each do |teacher, items|
        PaymentMailer.teacher_notification_email(teacher, current_user, order).deliver_later
      end
      PaymentMailer.student_receipt_email(current_user, order).deliver_later

      # Xóa giỏ hàng
      if current_user.cart.present?
        purchased_course_ids = order.order_items.pluck(:course_id)
        current_user.cart.cart_items.where(course_id: purchased_course_ids).destroy_all
      end

      redirect_to courses_path, notice: I18n.t("messages.orders.gmo_success")
    else
      # NẾU GMO TỪ CHỐI (Thẻ sai, hết hạn, từ chối giao dịch...)
      # Đá về trang checkout và hiện thông báo lỗi
      redirect_to gmo_checkout_order_path(order), alert: I18n.t("messages.orders.gmo_failed", error: result[:error])
    end
  end
end
