class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable,
        :confirmable

  enum :role, { student: 0, teacher: 1, admin: 2 }, default: :student

  has_many :courses
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :enrollments
  has_many :owned_courses, through: :enrollments, source: :course
  has_many :exam_attempts, dependent: :destroy
  has_many :practice_attempts, dependent: :destroy
  has_one :feedback_courses, dependent: :destroy
  has_many :likes, dependent: :destroy

  after_create :create_cart

  def teacher?
    role == "teacher"
  end

  def admin?
    role == "admin"
  end

  def liked?(feedback)
    likes.exists?(feedback_course_id: feedback.id)
  end

  def can_upload_course?
    bank_name.present? && bank_account_number.present? && bank_account_name.present?
  end

  protected

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def create_cart
    Cart.create(user: self)
  end
end