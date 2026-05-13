module TeacherRatingService
  def self.create_teacher_rating(teacher, new_rate)
    current_rate = teacher.rate || 0.0
    current_total_rating = teacher.total_rating || 0

    total_rating = current_rate * current_total_rating + new_rate
    average_rating = total_rating.to_f / (current_total_rating + 1)
    teacher.update(rate: average_rating, total_rating: current_total_rating + 1)
  end

  def self.update_teacher_rating(teacher, new_rate, old_rate)
    current_rate = teacher.rate || 0.0
    current_total_rating = teacher.total_rating || 0

    if current_total_rating > 0
      total_rating = current_rate * current_total_rating - old_rate + new_rate
      average_rating = total_rating.to_f / current_total_rating
      teacher.update(rate: average_rating, total_rating: current_total_rating)
    else
      teacher.update(rate: 0.0, total_rating: 0)
    end
  end
end
