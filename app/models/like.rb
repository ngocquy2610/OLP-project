class Like < ApplicationRecord
  belongs_to :user
  belongs_to :feedback_course
end
