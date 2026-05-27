class Exam < ApplicationRecord
  belongs_to :topic

  self.inheritance_column = nil

  enum :type, {
    multiple_choice: 1,
    true_false: 2
  }

  validates :question, presence: true
  validates :answers, presence: true
  validates :correct_answers, presence: true
  validates :type, presence: true
  validates :time_limit_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
