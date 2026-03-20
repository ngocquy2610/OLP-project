class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum :role, { student: 0, teacher: 1, admin: 2 }, default: :student
  has_many :courses
  has_one :cart, dependent: :destroy
  after_create :create_cart
  has_many :orders, dependent: :destroy
  has_many :enrollments
  has_many :owned_courses, through: :enrollments, source: :course

  def create_cart
    Cart.create(user: self)
  end

  def teacher?
    role == "teacher"
  end

  def admin?
    role == "admin"
  end
end
