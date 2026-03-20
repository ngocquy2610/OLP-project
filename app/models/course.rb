class Course < ApplicationRecord
  belongs_to :user
  has_one_attached :course_image
  has_many :topics, dependent: :destroy
  has_many :cart_items
  has_many :carts, through: :cart_items

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :course_image,
            attached: true,
            content_type: [ "image/png", "image/jpeg" ],
            size: { less_than: 5.megabytes, message: "File quá lớn (tối đa 5MB)" }
end
