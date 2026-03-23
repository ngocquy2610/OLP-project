class Management::ExamsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_exam, only: [ :show, :edit, :update, :destroy ]
  def index
    # Load topics available to the user (teachers see only their courses' topics)
    if current_user&.teacher?
      @topics = Topic.where(course_id: Course.where(user_id: current_user.id))
    else
      @topics = Topic.all
    end

    # Default selected topic = first available topic
    @selected_topic = if params[:topic_id].present?
                        @topics.find_by(id: params[:topic_id])
    else
                        @topics.first
    end

    # If no topics available, return empty set
    if @selected_topic
      @exams = Exam.where(topic_id: @selected_topic.id)
    else
      @exams = Exam.none
    end
  end

  def show
    @exam = Exam.find(params[:id])
  end

  def create
    # Support bulk create via params[:exams] (Option A)
    if params[:exams].present?
      created = []
      ActiveRecord::Base.transaction do
        params[:exams].each do |q|
          # skip completely blank rows
          next if q[:question].blank? && q[:answers].blank? && q[:correct_answers].blank?

          created << Exam.create!(
            topic_id: (q[:topic_id].presence || params[:topic_id].presence),
            question: q[:question],
            answers: q[:answers],
            correct_answers: q[:correct_answers],
            type: q[:type]
          )
        end
      end

      redirect_to management_exams_path, notice: "Tạo #{created.size} câu hỏi thành công"
    else
      @exam = Exam.new(exam_params)
      if @exam.save
        redirect_to new_management_lesson_path, notice: "Exam was successfully created."
      else
        render :new
      end
    end
  end

  def new
    @exam = Exam.new
  end

  def update
    if @exam.update(exam_params)
      redirect_to profile_path(current_user), notice: "Exam was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @exam.destroy
    redirect_to profile_path(current_user), notice: "Exam was successfully destroyed."
  end

  private

  def exam_params
    params.require(:exam).permit(:question, :answers, :correct_answers, :type, :topic_id)
  end

  def set_exam
    @exam = Exam.find(params[:id])
  end
end
