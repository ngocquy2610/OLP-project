class Management::LessonsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy ]
  before_action :set_owned_topics, only: [ :new, :create, :edit, :update ]
  def index
    @lessons = Lesson.all
    @lessons = @lessons.where(topic_id: Topic.where(course_id: Course.where(user_id: current_user.id))) if current_user&.teacher?
  end

  def show
    @practices = @lesson.practices
  end

  def create
    @lesson = Lesson.new(lesson_params)
    @lesson.video_blob_signed_id = build_video_blob_signed_id # assign the signed id of the new uploaded video to lesson.

    if owned_topic_selected? && @lesson.save
      redirect_to new_management_practice_path, notice: I18n.t("messages.management.lessons.created")
      @lesson.enqueue_video_attachment # run the background job.
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
    # if there is a new video uploaded, create a new blob and assign the signed id to lesson, if not, keep the old video.

    if owned_topic_selected? && @lesson.update(lesson_params)
      @lesson.enqueue_video_attachment # run the background job.
      redirect_to management_lessons_path(current_user), notice: I18n.t("messages.management.lessons.updated")
    else
      render :edit
    end
  end

  def destroy
    @lesson = Lesson.find_by(id: params[:id])
    @lesson.destroy
    redirect_to management_lessons_path(current_user), notice: I18n.t("messages.management.lessons.destroyed")
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
    # come into the hash (params) by the key [:lesson][:video], if the key is not exist, return nil instead of error.
    return if video_param.blank?

    blob = ActiveStorage::Blob.create_and_upload!(
      # !: raise exeption instead of returning false if the record is invalid
      # CREATE a new blob record and UPLOAD the file to storage, return the blob record
      io: video_param,
      filename: video_param.original_filename,
      content_type: video_param.content_type
    )

    blob.signed_id
  end

  def set_owned_topics
    @topics = Topic.joins(:course).where(courses: { user_id: current_user.id })
  end

  def owned_topic_selected?
    return true if @topics.exists?(id: @lesson.topic_id)

    @lesson.errors.add(:topic_id, :invalid)
    false
  end
end
