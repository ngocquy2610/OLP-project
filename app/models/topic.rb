class Topic < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :exam_attempts, dependent: :destroy

  validates :name, presence: true
end
