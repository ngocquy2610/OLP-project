class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :course

  # Quantity removed: each course can only be bought once
end
