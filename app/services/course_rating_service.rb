module CourseRatingService
  def self.create_course_rating(course, new_rate)

    current_rate = course.rate || 0.0
    current_total_rating = course.total_rating || 0

    total_rating = current_rate * current_total_rating + new_rate
    average_rating = total_rating.to_f / (current_total_rating + 1)
    course.update(rate: average_rating, total_rating: current_total_rating + 1)
  end

  def self.update_course_rating(course, new_rate, old_rate)

    current_rate = course.rate || 0.0
    current_total_rating = course.total_rating || 0

    if current_total_rating > 0
      total_rating = current_rate * current_total_rating - old_rate + new_rate
      average_rating = total_rating.to_f / current_total_rating
      course.update(rate: average_rating, total_rating: current_total_rating)
    else
      course.update(rate: 0.0, total_rating: 0)
    end
  end
end