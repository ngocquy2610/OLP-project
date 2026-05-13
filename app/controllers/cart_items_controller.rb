class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_user.cart
    course = Course.find_by(id: params[:course_id])

    if course.nil?
      redirect_back fallback_location: root_path, alert: I18n.t("messages.cart_items.course_not_found")
      return
    end

    item = cart.cart_items.find_by(course_id: course.id)

    if item
      respond_to do |format|
        format.html { redirect_to cart_path, alert: I18n.t("messages.cart_items.already_in_cart") }
        format.json { render json: { success: false, error: I18n.t("messages.cart_items.already_in_cart"), count: cart.cart_items.count } }
      end
    else
      item = cart.cart_items.new(course: course)

      if item.save
        respond_to do |format|
          format.html { redirect_to cart_path, notice: I18n.t("messages.cart_items.added") }
          format.json { render json: { success: true, count: cart.cart_items.count } }
        end
      else
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path, alert: item.errors.full_messages.to_sentence }
          format.json { render json: { success: false, error: item.errors.full_messages.to_sentence, count: cart.cart_items.count }, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    item = current_user.cart.cart_items.find_by(id: params[:id])
    if item
      item.destroy
      redirect_to cart_path, notice: I18n.t("messages.cart_items.removed")
    else
      redirect_to cart_path, alert: I18n.t("messages.cart_items.item_not_found")
    end
  end
end
