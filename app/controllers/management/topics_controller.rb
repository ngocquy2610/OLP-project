class Management::TopicsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_topic, only: [ :show, :edit, :update, :destroy ]

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
    if @topic.save
      redirect_to new_management_exam_path, notice: "Topic was successfully created."
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
    if @topic.update(topic_params)
      redirect_to profile_path(tab: "topics"), notice: "Topic was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @topic.destroy
    redirect_to profile_path(tab: "topics"), notice: "Topic was successfully destroyed."
  end

  private

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:name, :description, :course_id)
  end
end
