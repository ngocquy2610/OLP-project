class CartsController < ApplicationController
  before_action :authenticate_user!
  def show
    @cart = current_user.cart
    @total_quantity = @cart.cart_items.count
  end
end
