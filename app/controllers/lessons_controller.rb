class LessonsController < ApplicationController
  before_action :set_lesson, only: [ :practice, :submit_practice ]

  def practice
    @lesson = Lesson.find(params[:id])
    @practices = @lesson.practices
  end

  def submit_practice
    @lesson = Lesson.find(params[:id])
    @practices = @lesson.practices

    score = 0

    attempt = current_user.practice_attempts.create!(
      lesson: @lesson,
      score: 0
    )

    @practices.each do |practice|
      selected = params[:answers][practice.id.to_s]
      correct  = practice.correct_answers.strip

      is_correct = (selected == correct)
      score += 1 if is_correct
    end

    percentage = (score.to_f / @practices.count * 100).round(2)

    attempt.update(
      score: percentage,
      completed: percentage >= 80
    )

    redirect_to learn_course_path(@lesson.topic.course),
      notice: "Practice score: #{percentage}%"
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
