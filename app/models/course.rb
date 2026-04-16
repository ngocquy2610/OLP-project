class Course < ApplicationRecord
  belongs_to :user
  has_one_attached :course_image
  has_many :topics, dependent: :destroy
  has_many :cart_items
  has_many :carts, through: :cart_items
  has_many :feedback_courses
  has_many :users, through: :feedback_courses

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :price_must_be_zero_or_minimum

  enum :status, { pending: 0, published: 1, rejected: 2 }

  searchkick word_middle: [:name, :tag]

  def search_data
    {
      name: name,
      tag: tag,
      status: status_before_type_cast
    }
  end

  def price_must_be_zero_or_minimum
    return if price.nil?
    p = price.to_i
    if p != 0 && p < 20_000
      errors.add(:price, "must be 0 (free) or at least 20,000 VNĐ")
    end
  end
  validates :course_image,
            attached: true,
            content_type: [ "image/png", "image/jpeg" ],
            size: { less_than: 20.megabytes, message: "File quá lớn (tối đa 5MB)" }
end
