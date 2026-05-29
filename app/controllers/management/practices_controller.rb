class Management::PracticesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_practice, only: [ :show, :edit, :update, :destroy ]
  before_action :set_owned_lessons, only: [ :new, :create, :edit, :update ]
  def index
    base_lessons = if current_user&.teacher?
                     Lesson.where(topic_id: Topic.where(course_id: Course.where(user_id: current_user.id)))
    else
                     Lesson.all
    end

    @lesson_query = params[:lesson_query].to_s.strip
    @lessons = if @lesson_query.present?
                 normalized_query = ActiveRecord::Base.sanitize_sql_like(@lesson_query.downcase)
                 base_lessons.where("LOWER(lessons.name) LIKE ?", "%#{normalized_query}%")
    else
                 base_lessons
    end

    @selected_lesson = if params[:lesson_id].present?
                         @lessons.find_by(id: params[:lesson_id])
    end

    @practices = if @selected_lesson
                   Practice.where(lesson_id: @selected_lesson.id)
    elsif @lessons.exists?
                   Practice.where(lesson_id: @lessons.select(:id))
    else
                   Practice.none
    end
  end

  def show
    @practice = Practice.find_by(id: params[:id])
  end


  def create
    if params[:practices].present?
      created = []
      ActiveRecord::Base.transaction do
        params[:practices].each do |q|
          attributes = normalized_practice_attributes(q, lesson_id: q[:lesson_id].presence || params[:lesson_id].presence)
          next if attributes[:question].blank? && attributes[:answers].blank? && attributes[:correct_answers].blank?

          next unless @lessons.exists?(id: attributes[:lesson_id])

          created << Practice.create!(attributes)
        end
      end

      redirect_to management_practices_path, notice: I18n.t("messages.management.practices.bulk_created", count: created.size)
    else
      @practice = Practice.new(practice_params)
      if owned_lesson_selected? && @practice.save
        redirect_to profile_path(current_user), notice: I18n.t("messages.management.practices.created")
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
    @practice = Practice.find_by(id: params[:id])
    if owned_lesson_selected? && @practice.update(practice_params)
      redirect_to safe_return_to(management_practices_path), notice: I18n.t("messages.management.practices.updated")
    else
      render :edit
    end
  end

  def destroy
    @practice = Practice.find_by(id: params[:id])
    @practice.destroy
    redirect_to profile_path(current_user), notice: I18n.t("messages.management.practices.destroyed")
  end

  private

  def practice_params
    normalize_question_params(
      params.require(:practice).permit(:lesson_id, :question, :type, :time_limit_minutes, :correct_answer_index, :correct_answers, answers: [])
    )
  end

  def set_practice
    @practice = Practice.find_by(id: params[:id])
  end

  def set_owned_lessons
    @lessons = Lesson.joins(topic: :course).where(courses: { user_id: current_user.id })
  end

  def owned_lesson_selected?
    return true if @lessons.exists?(id: @practice.lesson_id)

    @practice.errors.add(:lesson_id, :invalid)
    false
  end

  def normalized_practice_attributes(question_params, lesson_id: nil)
    normalize_question_params(question_params).merge(lesson_id: lesson_id.presence).compact
  end

  def normalize_question_params(question_params)
    answers = normalized_answers(question_params[:answers])
    correct_answer = selected_correct_answer(question_params[:correct_answer_index], answers, question_params[:correct_answers])

    {
      lesson_id: question_params[:lesson_id],
      question: question_params[:question],
      answers: answers.join(","),
      correct_answers: correct_answer,
      type: question_params[:type],
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

  def safe_return_to(fallback_path)
    path = params[:return_to].to_s
    return fallback_path unless path.start_with?("/")

    path
  end
end
