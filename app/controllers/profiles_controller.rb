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
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = I18n.t("messages.profile.update_success")
          render turbo_stream: [
            turbo_stream.replace("profile_content", partial: "profiles/profile_content", locals: { user: @user }),
            turbo_stream.replace("flash_messages", partial: "layouts/flash")
          ]
        end
        format.html { redirect_to profile_path, notice: I18n.t("messages.profile.update_success") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render turbo_stream: [
            turbo_stream.replace("profile_content", partial: "profiles/profile_content", locals: { user: @user }),
            turbo_stream.replace("flash_messages", partial: "layouts/flash")
          ], status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(:fullname, :phone, :address, :bank_name, :bank_account_number, :bank_account_name, :stripe_account_id)
  end
end
