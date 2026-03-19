class Topic < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy
  has_many :exams, dependent: :destroy

  validates :name, presence: true
end
