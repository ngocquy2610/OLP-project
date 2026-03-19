class Management::PracticesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_practice, only: [ :show, :edit, :update, :destroy ]
  def index
    @practices = Practice.all
  end

  def show
    @practice = Practice.find(params[:id])
  end


  def create
    @practice = Practice.new(practice_params)
    if @practice.save
      redirect_to profile_path(current_user), notice: "Practice was successfully created."
    else
      render :new
    end
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
