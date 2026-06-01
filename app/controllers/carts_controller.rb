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

    unless voucher&.usable?
      redirect_to cart_path, alert: I18n.t("messages.cart.voucher_invalid")
      return
    end

    selected_ids = session[:selected_items]
    if selected_ids.blank?
      redirect_to cart_path, alert: I18n.t("messages.cart.select_items")
      return
    end

    subtotal = current_user.cart.cart_items.where(id: selected_ids).sum { |item| item.course.price.to_i }
    min_price = (voucher.active_price || 20_000).to_i

    if subtotal > min_price
      session[:voucher_id] = voucher.id
      redirect_to cart_path, notice: I18n.t("messages.cart.voucher_applied")
    else
      redirect_to cart_path, alert: I18n.t("messages.cart.min_total_after_voucher", min_price: min_price)
    end
  end

  def validate_voucher
    selected_ids = params[:selected_items]
    if selected_ids.blank?
      render json: { allowed: false, message: I18n.t("messages.cart.select_items") }, status: :unprocessable_entity
      return
    end

    items = current_user.cart.cart_items.where(id: selected_ids)
    subtotal = items.map { |item| item.course.price.to_i }.sum

    code = params[:code].to_s.upcase
    voucher = Voucher.find_by(code: code)
    unless voucher&.usable?
      render json: { allowed: false, message: I18n.t("messages.cart.voucher_invalid_or_expired") }, status: :unprocessable_entity
      return
    end

    min_price = (voucher.active_price || 20_000).to_i

    if subtotal > min_price
      render json: { allowed: true }
    else
      render json: { allowed: false, message: I18n.t("messages.cart.min_total_after_voucher", min_price: min_price) }, status: :unprocessable_entity
    end
  end

  def remove_voucher
    session[:voucher_id] = nil
    redirect_to cart_path, notice: I18n.t("messages.cart.voucher_removed")
  end

  def checkout
    selected_ids = params[:selected_items].presence || session.delete(:selected_items)

    if selected_ids.blank?
      redirect_to cart_path, alert: I18n.t("messages.cart.select_items")
      return
    end

    items = current_user.cart.cart_items.where(id: selected_ids)
    items = items.reject { |i| i.course.user_id == current_user.id }

    if items.empty?
      redirect_to cart_path, alert: I18n.t("messages.cart.no_valid_courses")
      return
    end

    subtotal = items.map { |item| item.course.price.to_i }.sum
    discount = 0
    voucher = nil


    if session[:voucher_id]
      voucher = Voucher.find_by(id: session[:voucher_id])
      min_price = (voucher&.active_price || 20_000).to_i

      unless voucher&.usable?
        session[:voucher_id] = nil
        voucher = nil
      else
        if subtotal > min_price
          discount = (subtotal * voucher.discount_percent.to_f / 100.0).round(0)
          voucher.increment!(:used_count)
          session[:voucher_id] = nil
        else
          session[:voucher_id] = nil
          redirect_to cart_path, alert: I18n.t("messages.cart.min_total_after_voucher", min_price: min_price)
          return
        end
      end
    end

    final_total = subtotal - discount

    order_attrs = {
      status: "pending",
      total: final_total,
      discount: discount
    }
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
