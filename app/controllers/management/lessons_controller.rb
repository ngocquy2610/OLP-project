class Management::LessonsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy ]
  def index
    @lessons = Lesson.all
  end

  def show
    @practices = @lesson.practices
  end

  def create
    @lesson = Lesson.new(lesson_params)
    if @lesson.save
      redirect_to profile_path(current_user), notice: "Lesson was successfully created."
    else
      render :new
    end
  end

  def new
    @lesson = Lesson.new
  end

  def update
    @lesson = Lesson.find(params[:id])
    if @lesson.update(lesson_params)
      redirect_to profile_path(current_user), notice: "Lesson was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    @lesson.destroy
    redirect_to profile_path(current_user), notice: "Lesson was successfully destroyed."
  end

  private

  def lesson_params
    params.require(:lesson).permit(:name, :video, :description, :topic_id)
  end

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
