class Lesson < ApplicationRecord
  belongs_to :topic
  has_many :practices, dependent: :destroy
  has_many :practice_attempts

  validates :name, presence: true
  has_one_attached :video
end
