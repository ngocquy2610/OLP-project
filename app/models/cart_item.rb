class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :course

  # Quantity removed: each course can only be bought once
  validate :cannot_add_own_course

  def cannot_add_own_course
    if course.user_id == cart.user_id
      errors.add(:base, "Bạn không thể mua khóa học của chính mình")
    end
  end
end
