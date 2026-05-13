class Management::CoursesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]
  before_action :require_banking_info!, only: [ :new, :create ]
  before_action :require_stripe_connection!, only: [ :new, :create ]

  def index
    @courses = Course.all
    @courses = @courses.where(user_id: current_user.id) if current_user&.teacher?
    render layout: false if turbo_frame_request?
  end

  def show
    authorize @course
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    @course.user = current_user
    @course.user_id = current_user.id

    authorize @course
    if @course.save
      redirect_to new_management_topic_path, notice: I18n.t("messages.management.courses.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to profile_path(current_user), notice: I18n.t("messages.management.courses.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    @course.destroy
    redirect_to profile_path(current_user), notice: I18n.t("messages.management.courses.destroyed")
  end

  private

  def set_course
    @course = Course.find_by(id: params[:id])
    unless @course
      redirect_to profile_path(current_user), alert: I18n.t("messages.management.courses.not_found")
    end
  end

  def course_params
    params.require(:course).permit(:name, :description, :price, :course_image, :tag)
  end

  def require_banking_info!
    unless current_user.can_upload_course?
      redirect_to edit_user_registration_path, alert: I18n.t("messages.management.courses.banking_required")
    end
  end

  def require_stripe_connection!
    if current_user.stripe_account_id.blank?
      redirect_to edit_user_registration_path, alert: I18n.t("messages.management.courses.stripe_required")
    end
  end
end
