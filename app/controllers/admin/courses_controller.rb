class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:published, :rejected]

  def index
    @pending_courses = Course.pending.order(created_at: :desc)
    @published_courses = Course.published.order(created_at: :desc)
    @rejected_courses = Course.rejected.order(created_at: :desc)
  end

  def published
    @course.published!
    redirect_to admin_courses_path, notice: 'Course has been published.'
  end

  def rejected
    @course.rejected!
    redirect_to admin_courses_path, notice: 'Course has been rejected.'
  end

  def show
    @course = Course.find(params[:id])
    @topics = @course.topics.includes(:exams).includes(lessons: [:practices, { video_attachment: :blob }])

    @exams_by_topic = @topics.map { |t| [t.id, t.exams] }.to_h
    @practices_by_lesson = @topics.flat_map(&:lessons).map { |l| [l.id, l.practices] }.to_h

    if params[:lesson_id]
      @current_lesson = Lesson.find(params[:lesson_id])
    else
      @current_lesson = @topics.first&.lessons&.first
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end
end