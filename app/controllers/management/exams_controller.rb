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
          attributes = normalized_exam_attributes(q, topic_id: q[:topic_id].presence || params[:topic_id].presence)
          next if attributes[:question].blank? && attributes[:answers].blank? && attributes[:correct_answers].blank? # skip if all fields are blank

          # if topic_id is present in question params, use it, otherwise use topic_id from main params
          next unless @topics.exists?(id: attributes[:topic_id]) # skip if topic_id is not in owned topics

          created << Exam.create!(attributes)
        end
      end

      # transaction
      # - save all or nothing
      # - the database is always in a valid state
      # - other transactions cannot see its uncommitted changes
      # - Saved means saved
      # after_commit - after the transaction is committed, execute the block
      # after_save - still inside the transaction. run after SQL, but not committed yet.
      # MVC - interaction --> routes --> controller --> model --> database --> controller --> view.
      # schema - the summary of database structure.
      # config

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
    normalize_question_params(
      params.require(:exam).permit(:question, :type, :topic_id, :time_limit_minutes, :correct_answer_index, :correct_answers, answers: [])
    )
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

  def normalized_exam_attributes(question_params, topic_id: nil)
    normalize_question_params(question_params).merge(topic_id: topic_id.presence).compact
  end

  def normalize_question_params(question_params)
    answers = normalized_answers(question_params[:answers])
    correct_answer = selected_correct_answer(question_params[:correct_answer_index], answers, question_params[:correct_answers])

    {
      question: question_params[:question],
      answers: answers.join(","),
      correct_answers: correct_answer,
      type: question_params[:type],
      topic_id: question_params[:topic_id],
      time_limit_minutes: question_params[:time_limit_minutes]
    }
  end

  def normalized_answers(raw_answers)
    Array(raw_answers).flat_map { |answer| answer.to_s.split(",") }.map(&:strip).reject(&:blank?)
  end

  def selected_correct_answer(correct_answer_index, answers, fallback_correct_answer)
    if correct_answer_index.present?
      answers[correct_answer_index.to_i].to_s.strip
    else
      fallback_correct_answer.to_s.strip
    end
  end
end
