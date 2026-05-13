class FeedbackCoursesController < ApplicationController
  before_action :authenticate_user!

  before_action :set_course

  before_action :set_feedback, only: [ :edit, :update ]
  before_action :authorize_user!, only: [ :edit, :update ]

  def index
    @feedbacks = @course.feedback_courses.order(created_at: :desc).page(params[:page]).per(10)
  end

  def create
    @feedback = @course.feedback_courses.build(feedback_params)
    @feedback.user = current_user

    unless current_user.owned_courses.exists?(@course.id)
      redirect_to @course, alert: I18n.t("messages.feedback.purchase_required")
      return
    end

    if @feedback.save
      redirect_to @course, notice: I18n.t("messages.feedback.created")
    else
      redirect_to @course, alert: I18n.t("messages.feedback.create_error")
    end


    CourseRatingService.create_course_rating(@course, @feedback.rate)
    TeacherRatingService.create_teacher_rating(@course.user, @feedback.rate)
  end

  def edit
  end

  def update
    old_rate = @feedback.rate || 0.0
    if @feedback.update(feedback_params)
      redirect_to @course, notice: I18n.t("messages.feedback.updated")
    else
      render :edit, status: :unprocessable_entity
    end

    CourseRatingService.update_course_rating(@course, @feedback.rate, old_rate)
    TeacherRatingService.update_teacher_rating(@course.user, @feedback.rate, old_rate)
  end

  def like
    @feedback = @course.feedback_courses.find_by(id: params[:id])
    @feedback.increment!(:likes_count)
    redirect_to @course, notice: I18n.t("messages.feedback.liked")
  end

  private

  def set_course
    @course = Course.find_by(id: params[:course_id])
  end

  def set_feedback
    @feedback = @course.feedback_courses.find_by(id: params[:id])
  end

  def authorize_user!
    unless @feedback.user_id == current_user.id
      redirect_to @course, alert: I18n.t("messages.feedback.edit_forbidden")
    end
  end

  def feedback_params
    params.require(:feedback_course).permit(:feedback, :rate)
  end
end
