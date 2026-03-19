class Management::ExamsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_exam, only: [ :show, :edit, :update, :destroy ]
  def index
    @exams = Exam.all
  end

  def show
    @exam = Exam.find(params[:id])
  end

  def create
    @exam = Exam.new(exam_params)
    if @exam.save
      redirect_to profile_path(current_user), notice: "Exam was successfully created."
    else
      render :new
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
