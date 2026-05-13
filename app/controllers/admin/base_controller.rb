class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    unless current_user.role == "admin"
      flash[:alert] = I18n.t("messages.admin.access_denied")
      redirect_to root_path
    end
  end
end
