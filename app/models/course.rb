class Course < ApplicationRecord
  belongs_to :user
  has_one_attached :course_image, dependent: :destroy do |attachable|
    attachable.variant :webp_small,
                       format: :webp,
                       resize_to_limit: [ 400, 400 ],
                       saver: { quality: 75 },
                       preprocessed: true

    attachable.variant :webp_medium,
                       format: :webp,
                       resize_to_limit: [ 800, 800 ],
                       saver: { quality: 80 },
                       preprocessed: true

    attachable.variant :webp_large,
                       format: :webp,
                       resize_to_limit: [ 1200, 1200 ],
                       saver: { quality: 85 },
                       preprocessed: true

    attachable.variant :webp_thumb,
                       format: :webp,
                       resize_to_fill: [ 160, 96 ],
                       saver: { quality: 75 },
                       preprocessed: true
  end
  has_many :topics, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items, dependent: :destroy
  has_many :feedback_courses, dependent: :destroy
  has_many :users, through: :feedback_courses
  has_many :enrollments, dependent: :destroy
  has_many :order_items, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :price_must_be_zero_or_minimum

  # scope :published, -> { where(status: "published") }

  enum :status, { pending: 0, published: 1, rejected: 2 }

  searchkick word_middle: [ :name, :tag ]

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
            content_type: [ "image/png", "image/jpeg", "image/webp" ],
            size: { less_than: 20.megabytes, message: "File quá lớn (tối đa 5MB)" }

  def optimized_image
    return unless course_image.attached?

    course_image.variant(:webp_large).processed
  end
end

# Scope - using in model. ex: scope :published, -> { where(status: "published") }
# create! --> raise exception