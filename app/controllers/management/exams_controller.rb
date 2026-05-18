class Management::ExamsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_exam, only: [ :show, :edit, :update, :destroy ]
  before_action :set_owned_topics, only: [ :new, :create, :edit, :update ]
  def index
    if current_user&.teacher?
      @topics = Topic.where(course_id: Course.where(user_id: current_user.id))
    else
      @topics = Topic.all
    end

    @selected_topic = if params[:topic_id].present?
                        @topics.find_by(id: params[:topic_id])
    else
                        @topics.first
    end

    if @selected_topic
      @exams = Exam.where(topic_id: @selected_topic.id)
    else
      @exams = Exam.none
    end
  end

  def show
    @exam = Exam.find_by(id: params[:id])
  end

  def create
    if params[:exams].present?
      created = []
      ActiveRecord::Base.transaction do # working if all function inside transaction block is successful, otherwise rollback
        params[:exams].each do |q|
          next if q[:question].blank? && q[:answers].blank? && q[:correct_answers].blank? # skip if all fields are blank

          topic_id = (q[:topic_id].presence || params[:topic_id].presence)
          # if topic_id is present in question params, use it, otherwise use topic_id from main params
          next unless @topics.exists?(id: topic_id) # skip if topic_id is not in owned topics

          created << Exam.create!(
            topic_id: topic_id,
            question: q[:question],
            answers: q[:answers],
            correct_answers: q[:correct_answers],
            type: q[:type]
          )
        end
      end

      redirect_to new_management_lesson_path, notice: I18n.t("messages.management.exams.bulk_created", count: created.size)
    else
      @exam = Exam.new(exam_params)
      if owned_topic_selected? && @exam.save
        redirect_to new_management_lesson_path, notice: I18n.t("messages.management.exams.created")
      else
        render :new
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    @exam = Exam.new
    render :new
  # raise exception
  end

  def new
    @exam = Exam.new
  end

  def update
    if owned_topic_selected? && @exam.update(exam_params)
      redirect_to profile_path(current_user), notice: I18n.t("messages.management.exams.updated")
    else
      render :edit
    end
  end

  def destroy
    @exam.destroy
    redirect_to profile_path(current_user), notice: I18n.t("messages.management.exams.destroyed")
  end

  private

  def exam_params
    params.require(:exam).permit(:question, :answers, :correct_answers, :type, :topic_id)
  end

  def set_exam
    @exam = Exam.find_by(id: params[:id])
  end

  def set_owned_topics
    @topics = Topic.joins(:course).where(courses: { user_id: current_user.id }) # get topics that belong to courses owned by current user
  end

  def owned_topic_selected?
    return true if @topics.exists?(id: @exam.topic_id) # check if the selected topic is in owned topics, if true return true

    @exam.errors.add(:topic_id, :invalid) # add error to topic_id field if the selected topic is not in owned topics
    false
  end
end
