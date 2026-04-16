class FeedbackCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :likes, dependent: :destroy
end
