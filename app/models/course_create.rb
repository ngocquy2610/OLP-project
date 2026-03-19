class CourseCreate < ApplicationRecord
  belongs_to :course
  belongs_to :user # teacher
end
