class Management::CoursesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]

  def index
    @courses = Course.all
    @courses = @courses.where(user_id: current_user.id) if current_user&.teacher?
    render layout: false if turbo_frame_request?
  end

  def show
    authorize @course
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    @course.user = current_user
    @course.user_id = current_user.id

    authorize @course
    if @course.save
      redirect_to new_management_topic_path, notice: "Course was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to profile_path(current_user), notice: "Course was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    @course.destroy
    redirect_to profile_path(current_user), notice: "Course was successfully destroyed."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profile_path(current_user), alert: "Không tìm thấy khóa học này."
  end

  def course_params
    params.require(:course).permit(:name, :description, :price, :course_image)
  end
end
