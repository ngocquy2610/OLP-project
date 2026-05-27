class TopicsController < ApplicationController
  def exam
    @topic = Topic.find_by(id: params[:id])
    @exams = @topic.exams
    session[exam_session_key] ||= Time.current.to_i
  end

  def submit_exam
    @topic = Topic.find_by(id: params[:id])
    @exams = @topic.exams

    if exam_time_expired?
      session.delete(exam_session_key)
      redirect_to learn_course_path(@topic.course), alert: I18n.t("messages.assessments.exam_time_up") and return
    end

    answers = params[:answers] || {}

    missing = @exams.map { |e| e.id.to_s } - answers.keys
    if missing.any?
      redirect_to exam_topic_path(@topic), alert: I18n.t("messages.assessments.complete_before_submit") and return
    end

    score = 0

    attempt = current_user.exam_attempts.create!(topic: @topic, score: 0)

    @exams.each do |exam|
      selected = answers[exam.id.to_s]
      correct  = exam.correct_answers.strip

      score += 1 if selected == correct
    end

    redirect_to learn_course_path(@topic.course),
      notice: I18n.t("messages.assessments.exam_score", score: score, total: @exams.count)
    @score = score/@exams.count.to_f
    @score = (@score * 100).round(2)
    attempt.update(score: @score)
    if @score >= 80
      attempt.update(completed: true)
    else
      attempt.update(completed: false)
    end

    session.delete(exam_session_key)
  end

  private

  def exam_session_key
    "exam_started_at_#{params[:id]}"
  end

  def exam_time_expired?
    started_at = session[exam_session_key].to_i
    return false if started_at <= 0

    limit_seconds = @exams.first&.time_limit_minutes.to_i * 60
    return false if limit_seconds <= 0

    (Time.current.to_i - started_at) > limit_seconds
  end
end
