class TopicsController < ApplicationController
  def exam
    @topic = Topic.find(params[:id])
    @exams = @topic.exams
  end

  def submit_exam
    @topic = Topic.find(params[:id])
    @exams = @topic.exams

    score = 0

    attempt = current_user.exam_attempts.create!(topic: @topic, score: 0)

    @exams.each do |exam|
      selected = params[:answers][exam.id.to_s]
      correct  = exam.correct_answers.strip

      score += 1 if selected == correct
    end

    redirect_to learn_course_path(@topic.course),
      notice: "Your score: #{score}/#{@exams.count}"
    @score = score/@exams.count.to_f
    @score = (@score * 100).round(2)
    attempt.update(score: @score)
    if @score >= 80
      attempt.update(completed: true)
    else
      attempt.update(completed: false)
    end
  end
end
