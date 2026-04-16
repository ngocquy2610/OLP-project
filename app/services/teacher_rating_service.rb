module TeacherRatingService
  def self.create_teacher_rating(teacher, new_rate)
    #take all course belong to teacher and calculate average rating
    courses = teacher.courses
    total_rate = courses.sum(:rate)
    total_course = courses.count
    average_rate = total_course > 0 ? total_rate.to_f / total_course : 0.0
    teacher.update(rate: average_rate)
  end
end