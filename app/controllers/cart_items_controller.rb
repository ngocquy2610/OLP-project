class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_user.cart
    course = Course.find_by(id: params[:course_id])

    if course.nil?
      redirect_back fallback_location: root_path, alert: "Khóa học không tồn tại"
      return
    end

    item = cart.cart_items.find_by(course_id: course.id)

    if item
      respond_to do |format|
        format.html { redirect_to cart_path, alert: "Đã có trong giỏ hàng" }
        format.json { render json: { success: false, error: "Đã có trong giỏ hàng", count: cart.cart_items.count } }
      end
    else
      item = cart.cart_items.new(course: course)

      if item.save
        respond_to do |format|
          format.html { redirect_to cart_path, notice: "Added to cart" }
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
      redirect_to cart_path, notice: "Removed"
    else
      redirect_to cart_path, alert: "Item not found"
    end
  end
end
