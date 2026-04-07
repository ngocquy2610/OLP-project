class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  
  before_action :require_admin!
  
  layout 'admin'

  private

  def require_admin!
    unless current_user.role == 'admin' 
      flash[:alert] = "Access Denied. You are not authorized to view this page."
      redirect_to root_path
    end
  end
end