class Admin::ManagementController < ApplicationController
    before_action :authenticate_user!

    def index
        @users = User.where.not(role: "admin").order(:id)
    end

    def destroy
        @user = User.find_by(id: params[:id])
        if @user.destroy
            flash[:notice] = I18n.t("messages.admin.management.user_deleted")
        else
            flash[:alert] = I18n.t("messages.admin.management.user_delete_failed")
        end
        redirect_to admin_management_path
    end

    def update
        @user = User.find_by(id: params[:id])
        new_role = @user.role == "student" ? "teacher" : "student"
        if @user.update(role: new_role)
            flash[:notice] = I18n.t("messages.admin.management.user_role_updated", role: new_role)
        else
            flash[:alert] = I18n.t("messages.admin.management.user_role_update_failed")
        end
        redirect_to admin_management_path
    end
end
