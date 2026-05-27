class LessonsController < ApplicationController
  before_action :set_lesson, only: [ :practice, :submit_practice ]

  def practice
    @practices = @lesson.practices
    session[practice_session_key] ||= Time.current.to_i
  end

  def submit_practice
    @practices = @lesson.practices

    if practice_time_expired?
      session.delete(practice_session_key)
      redirect_to learn_course_path(@lesson.topic.course), alert: I18n.t("messages.assessments.practice_time_up") and return
    end

    answers = params[:answers] || {}

    missing = @practices.map { |p| p.id.to_s } - answers.keys
    if missing.any?
      redirect_to practice_lesson_path(@lesson), alert: I18n.t("messages.assessments.complete_before_submit") and return
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

    session.delete(practice_session_key)

    redirect_to learn_course_path(@lesson.topic.course),
      notice: I18n.t("messages.assessments.practice_score", percentage: percentage)
  end

  private

  def set_lesson
    @lesson = Lesson.find_by(id: params[:id])
  end

  def practice_session_key
    "practice_started_at_#{params[:id]}"
  end

  def practice_time_expired?
    started_at = session[practice_session_key].to_i
    return false if started_at <= 0

    limit_seconds = @practices.first&.time_limit_minutes.to_i * 60
    return false if limit_seconds <= 0

    (Time.current.to_i - started_at) > limit_seconds
  end
end
