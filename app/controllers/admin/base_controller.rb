class Admin::BaseController < ApplicationController
  before_action :authenticate_user! # Only authenticated users can access admin controllers
  before_action :require_admin! # Only admin users can access admin controllers

  private

  def require_admin!
    unless current_user.role == "admin" # Check if the current user's role is "admin"
      flash[:alert] = I18n.t("messages.admin.access_denied") # Set an alert message for access denied
      redirect_to root_path # Redirect to the root path if the user is not an admin
    end
  end
end
