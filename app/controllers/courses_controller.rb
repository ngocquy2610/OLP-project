class CoursesController < ApplicationController
  def index
    @courses = Course.all
    render "courses/index"
  end

  def show
    @course = Course.find(params[:id])
    @topics = @course.topics.includes(:lessons)
    render "courses/show"
  end
end
