class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_user.cart
    course = Course.find(params[:course_id])

    if course.user_id == current_user.id
      redirect_back fallback_location: root_path,
        alert: "Bạn không thể mua khóa học của chính mình"
      return
    end

    item = cart.cart_items.find_by(course_id: course.id)

    if item
      redirect_to cart_path, alert: "Course already in cart"
    else
      item = cart.cart_items.new(course: course)

      if item.save
        redirect_to cart_path, notice: "Added to cart"
      else
        redirect_back fallback_location: root_path,
          alert: item.errors.full_messages.to_sentence
      end
    end
  end

  def destroy
    item = current_user.cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path, notice: "Removed"
  end
end
