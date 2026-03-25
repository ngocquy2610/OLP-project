class PracticeAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  has_many :practice_answers, dependent: :destroy
end
