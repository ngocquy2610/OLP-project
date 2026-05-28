class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :course

  # Quantity removed: each course can only be bought once
  validate :cannot_add_own_course

  def cannot_add_own_course
    if course.user_id == cart.user_id
      errors.add(:base, I18n.t("errors.models.cart_item.attributes.base.cannot_buy_own_course"))
    end
  end
end
