class ProfilesController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Cập nhật hồ sơ thành công!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    # Chỉ cho phép sửa các trường thông tin cá nhân, KHÔNG cho sửa role ở đây để bảo mật
    params.require(:user).permit(:fullname, :phone, :address)
  end
end
