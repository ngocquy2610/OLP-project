class Admin::ManagementController < ApplicationController
    before_action :authenticate_user!

    def index
        @users = User.where.not(role: 'admin').order(:id)
    end

    def destroy
        @user = User.find_by(id: params[:id])
        if @user.destroy
            flash[:notice] = "User deleted successfully."
        else
            flash[:alert] = "Failed to delete user."
        end
        redirect_to admin_management_path
    end

    def update
        @user = User.find_by(id: params[:id])
        if params[:user].present?
            if @user.update(user_params)
                flash[:notice] = "User updated successfully."
            else
                flash[:alert] = "Failed to update user."
            end
        else
            new_role = @user.role == 'student' ? 'teacher' : 'student'
            if @user.update(role: new_role)
                flash[:notice] = "User role updated to #{new_role}."
            else
                flash[:alert] = "Failed to update user role."
            end
        end
        redirect_to admin_management_path
    end

    private

    def user_params
        params.require(:user).permit(:fullname, :email, :role)
    end

end