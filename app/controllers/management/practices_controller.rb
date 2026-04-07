class Management::PracticesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_practice, only: [ :show, :edit, :update, :destroy ]
  def index
    if current_user&.teacher?
      @lessons = Lesson.where(topic_id: Topic.where(course_id: Course.where(user_id: current_user.id)))
    else
      @lessons = Lesson.all
    end

    @selected_lesson = if params[:lesson_id].present?
                         @lessons.find_by(id: params[:lesson_id])
    else
                         @lessons.first
    end

    if @selected_lesson
      @practices = Practice.where(lesson_id: @selected_lesson.id)
    else
      @practices = Practice.none
    end
  end

  def show
    @practice = Practice.find(params[:id])
  end


  def create
    if params[:practices].present?
      created = []
      ActiveRecord::Base.transaction do
        params[:practices].each do |q|
          next if q[:question].blank? && q[:answers].blank? && q[:correct_answers].blank?

          created << Practice.create!(
            lesson_id: (q[:lesson_id].presence || params[:lesson_id].presence),
            question: q[:question],
            answers: q[:answers],
            correct_answers: q[:correct_answers],
            type: q[:type]
          )
        end
      end

      redirect_to management_practices_path, notice: "Tạo #{created.size} câu hỏi thành công"
    else
      @practice = Practice.new(practice_params)
      if @practice.save
        redirect_to profile_path(current_user), notice: "Practice was successfully created."
      else
        render :new
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    @practice = Practice.new
    render :new
  end

  def new
    @practice = Practice.new
  end

  def update
    @practice = Practice.find(params[:id])
    if @practice.update(practice_params)
      redirect_to profile_path(current_user), notice: "Practice was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @practice = Practice.find(params[:id])
    @practice.destroy
    redirect_to profile_path(current_user), notice: "Practice was successfully destroyed."
  end

  private

  def practice_params
    params.require(:practice).permit(:lesson_id, :question, :answers, :correct_answers, :type)
  end

  def set_practice
    @practice = Practice.find(params[:id])
  end
end
