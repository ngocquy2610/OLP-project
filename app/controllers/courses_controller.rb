class CoursesController < ApplicationController
  def index
    @courses = Course.all
    render "courses/index"
  end

  def show
    @course = Course.find(params[:id])
    @topics = @course.topics.includes(:lessons)
    render "courses/show"

    # Check ownership
    @owned = current_user&.owned_courses&.exists?(@course.id)

    if @owned
      # FULL DATA (only for buyers)
      @lessons = @course.topics.includes(:lessons).flat_map(&:lessons)
      @exams = @course.topics.includes(:exams).flat_map(&:exams)
      @practices = @lessons.includes(:practices).flat_map(&:practices)
    else
      # LIMITED DATA (public)
      @lessons = @course.topics.includes(:lessons).flat_map(&:lessons) # preview only
      @exams   = [] # or hide completely
      @practices = [] # or hide completely
    end
  end

  def my_courses
    @courses = current_user.owned_courses
  end
end
