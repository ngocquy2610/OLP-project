class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [ :published, :rejected ]

  def index
    @pending_courses = Course.pending.order(created_at: :desc).page(params[:page]).per(10)
    # Course.pending.order(created_at: :desc) fetches all courses with "pending" status
    # .page(params[:page]).per(10): paginates the results, showing 10 courses per page
  end

  def published
    @course.published! # Change the course status to "published"
    redirect_to admin_courses_path, notice: I18n.t("messages.admin.courses.published")
  end

  def rejected
    @course.rejected! # Change the course status to "rejected"
    redirect_to admin_courses_path, notice: I18n.t("messages.admin.courses.rejected")
  end

  def show
    @course = Course.find_by(id: params[:id])
    @topics = @course.topics.includes(:exams).includes(lessons: [ :practices, { video_attachment: :blob } ])
    # @course.topics.includes(:exams): fetches all topics, including their exams, for the given course
    # .includes(lessons: [ :practices, { video_attachment: :blob } ]): also includes lessons and their practices, as well as any video attachments for the lessons

    # :blob is the Binary Large Object. Use for image, video storage.
    # blob = lesson.video_attachment.blob

    # blob.filename      # => "intro.mp4"
    # blob.content_type  # => "video/mp4"
    # blob.byte_size     # => 10485760  (bytes)
    # blob.checksum      # => "abc123..."
    # blob.key           # => "xyz789..." (tên file trên S3/storage)
    # blob.created_at    # => 2024-01-15

    @exams_by_topic = @topics.map { |t| [ t.id, t.exams ] }.to_h
    # @topics.map { |t| [ t.id, t.exams ] } creates an array. Each element is a pair [ topic_id, exams_for_that_topic ].
    # .to_h converts the array of pairs into a hash, where the keys are topic IDs and the values are the exams
    # using hash to allow search by id when render view.

    @practices_by_lesson = @topics.flat_map(&:lessons).map { |l| [ l.id, l.practices ] }.to_h
    # @topics.flat_map(&:lessons) flattens all lessons from all topics into a single array of lessons
    # .map { |l| [ l.id, l.practices ] } creates an array of pairs [ lesson_id, practices_for_that_lesson ]
    # .to_h converts the array of pairs into a hash, where the keys are lesson IDs and the values are the practices
    # using hash to allow search by id when render view.

    # using flat_map to take just a single array include all lessons of all topics.
    # If use map, it will return an array of array of lessons.

    if params[:lesson_id]
      @current_lesson = Lesson.find_by(id: params[:lesson_id])
    else
      @current_lesson = @topics.first&.lessons&.first
    end
    # show the lessons by id, if no param sending from view, show the first lesson of first topic.
  end

  private

  def set_course
    @course = Course.find_by(id: params[:id])
  end
end
