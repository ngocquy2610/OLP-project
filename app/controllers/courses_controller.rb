class CoursesController < ApplicationController
  def index
    if params[:query].present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query].strip)}%"
      @courses = Course.published
                       .where("name ILIKE :query OR tag ILIKE :query", query: query)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(12)
    else
      @courses = Course.published.page(params[:page]).per(12)
    end
  end

  def show
    @course = Course.find_by(id: params[:id])
    if @course.nil?
      redirect_to courses_path, alert: I18n.t("messages.courses.not_found")
      return
    end
    @topics = @course.topics.includes(:lessons)
    teacher = @course.user
    @teacher_rating = teacher.rate
    @teacher_name = teacher.fullname

    @owned = current_user&.owned_courses&.exists?(@course.id)

    if @owned
      @lessons = @course.topics.includes(:lessons).flat_map(&:lessons)
      @exams = @course.topics.includes(:exams).flat_map(&:exams)
      @practices = @course.topics
                   .includes(lessons: :practices)
                   .flat_map(&:lessons)
                   .flat_map(&:practices)
    else
      @lessons = @course.topics.includes(:lessons).flat_map(&:lessons)
      @exams   = []
      @practices = []
    end
  end

  def learn
    @course = Course.find_by(id: params[:id])
    if @course.nil?
      redirect_to courses_path, alert: I18n.t("messages.courses.not_found")
      return
    end

    unless current_user.owned_courses.exists?(@course.id)
      redirect_to course_path(@course), alert: I18n.t("messages.courses.not_purchased")
      return
    end

    @topics = @course.topics.includes(:lessons)

    if current_user
      exam_attempts = current_user.exam_attempts
                            .where(topic_id: @topics.map(&:id))
                            .order(score: :desc)
      @highest_attempts = exam_attempts.group_by(&:topic_id).transform_values(&:first)
      @score = @highest_attempts.values.map(&:score).compact


      lesson_ids = @topics.flat_map(&:lessons).map(&:id)
      practice_attempts = current_user.practice_attempts
                                .where(lesson_id: lesson_ids)
                                .order(score: :desc)
      @last_practice_attempts = practice_attempts.group_by(&:lesson_id).transform_values(&:first)
    else
      @highest_attempts = {}
      @score = []
      @last_practice_attempts = {}
    end

    if params[:lesson_id]
      @current_lesson = Lesson.find_by(id: params[:lesson_id])
    else
      @current_lesson = @topics.first&.lessons&.first
    end
  end

  def my_courses
    @courses = current_user.owned_courses
  end
end
