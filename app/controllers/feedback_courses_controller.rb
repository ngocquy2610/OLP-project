class FeedbackCoursesController < ApplicationController
  before_action :authenticate_user! 
  
  before_action :set_course
  
  before_action :set_feedback, only: [:edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def index
    @feedbacks = @course.feedback_courses.order(created_at: :desc).page(params[:page]).per(10)
  end

  def create
    @feedback = @course.feedback_courses.build(feedback_params)
    @feedback.user = current_user 

    unless current_user.owned_courses.exists?(@course.id)
      redirect_to @course, alert: "Bạn phải mua khóa học này mới được đánh giá!"
      return
    end

    if @feedback.save
      redirect_to @course, notice: "Cảm ơn bạn đã gửi đánh giá!"
    else
      redirect_to @course, alert: "Có lỗi xảy ra, vui lòng nhập nội dung đánh giá."
    end
  end

  def edit
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @course, notice: "Đánh giá của bạn đã được cập nhật!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_feedback
    @feedback = @course.feedback_courses.find(params[:id])
  end

  # HÀM BẢO MẬT QUAN TRỌNG: Chỉ chủ nhân của feedback mới được quyền sửa
  def authorize_user!
    unless @feedback.user_id == current_user.id
      redirect_to @course, alert: "Bạn không có quyền sửa đánh giá của người khác!"
    end
  end

  def feedback_params
    params.require(:feedback_course).permit(:feedback, :rate)
  end
end