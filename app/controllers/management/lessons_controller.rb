class Management::LessonsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy ]
  def index
    @lessons = Lesson.all
    @lessons = @lessons.where(topic_id: Topic.where(course_id: Course.where(user_id: current_user.id))) if current_user&.teacher?
  end

  def show
    @practices = @lesson.practices
  end

  def create
    Rails.logger.debug "[LessonsController#create] params[:lesson]=#{params[:lesson].inspect}"
    @lesson = Lesson.new(lesson_params)
    @lesson.video_blob_signed_id = build_video_blob_signed_id

    if @lesson.save
      redirect_to new_management_practice_path, notice: "Lesson was successfully created."
      @lesson.enqueue_video_attachment
    else
      render :new
    end

  end

  def new
    @lesson = Lesson.new
  end

  def update
    @lesson = Lesson.find_by(id: params[:id])
    Rails.logger.debug "[LessonsController#update] params[:lesson]=#{params[:lesson].inspect}"
    @lesson.video_blob_signed_id = build_video_blob_signed_id

    if @lesson.update(lesson_params)
      @lesson.enqueue_video_attachment
      redirect_to management_lessons_path(current_user), notice: "Lesson was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @lesson = Lesson.find_by(id: params[:id])
    @lesson.destroy
    redirect_to management_lessons_path(current_user), notice: "Lesson was successfully destroyed."
  end

  private

  def lesson_params
    params.require(:lesson).permit(:name, :description, :topic_id)
  end

  def set_lesson
    @lesson = Lesson.find_by(id: params[:id])
  end

  def build_video_blob_signed_id
    video_param = params.dig(:lesson, :video)
    return if video_param.blank?

    blob = ActiveStorage::Blob.create_and_upload!(
      io: video_param,
      filename: video_param.original_filename,
      content_type: video_param.content_type
    )

    blob.signed_id
  end

end
