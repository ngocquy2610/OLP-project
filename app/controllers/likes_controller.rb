class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_feedback

  def create
    @feedback.likes.find_or_create_by(user: current_user)

    render turbo_stream: turbo_stream.replace(
      "like_button_#{@feedback.id}",
      partial: "likes/button",
      locals: { feedback: @feedback }
    )
  end

  def destroy
    like = @feedback.likes.find_by(user: current_user)
    like&.destroy

    render turbo_stream: turbo_stream.replace(
      "like_button_#{@feedback.id}",
      partial: "likes/button",
      locals: { feedback: @feedback }
    )
  end

  private

  def set_feedback
    @feedback = FeedbackCourse.find_by(id: params[:feedback_course_id])
  end
end
