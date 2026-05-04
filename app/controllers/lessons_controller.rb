class LessonsController < ApplicationController
  before_action :set_lesson, only: [ :practice, :submit_practice ]

  def practice
    @lesson = Lesson.find_by(id: params[:id])
    @practices = @lesson.practices
  end

  def submit_practice
    @lesson = Lesson.find_by(id: params[:id])
    @practices = @lesson.practices

    answers = params[:answers] || {}

    missing = @practices.map { |p| p.id.to_s } - answers.keys
    if missing.any?
      redirect_to practice_lesson_path(@lesson), alert: 'Hãy hoàn thành toàn bộ bài kiểm tra trước khi nộp bài.' and return
    end

    score = 0

    attempt = current_user.practice_attempts.create!(
      lesson: @lesson,
      score: 0
    )

    @practices.each do |practice|
      selected = answers[practice.id.to_s]
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
    @lesson = Lesson.find_by(id: params[:id])
  end
end
