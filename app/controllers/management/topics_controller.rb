class Management::TopicsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_topic, only: [ :show, :edit, :update, :destroy ]
  before_action :set_owned_courses, only: [ :new, :create, :edit, :update ]

  def index
    @topics = Topic.all
    @topics = @topics.where(course_id: Course.where(user_id: current_user.id)) if current_user&.teacher?
  end

  def show
    @lessons = @topic.lessons
    @exams = @topic.exams
  end

  def create
    @topic = Topic.new(topic_params)
    if owned_course_selected? && @topic.save
      redirect_to new_management_exam_path, notice: I18n.t("messages.management.topics.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @topic = Topic.new
  end

  def edit
    @topic
  end

  def update
    if owned_course_selected? && @topic.update(topic_params)
      redirect_to profile_path(tab: "topics"), notice: I18n.t("messages.management.topics.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @topic.destroy
    redirect_to profile_path(tab: "topics"), notice: I18n.t("messages.management.topics.destroyed")
  end

  private

  def set_topic
    @topic = Topic.find_by(id: params[:id])
  end

  def topic_params
    params.require(:topic).permit(:name, :description, :course_id)
  end

  def set_owned_courses
    @courses = Course.where(user_id: current_user.id)
  end

  def owned_course_selected?
    return true if @courses.exists?(id: @topic.course_id)

    @topic.errors.add(:course_id, :invalid)
    false
  end
end
