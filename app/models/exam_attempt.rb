class ExamAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :topic
  has_many :answers

  def passed?
    completed == true || completed == 1
  end

  def status
    passed? ? "Passed" : "Failed"
  end
end
