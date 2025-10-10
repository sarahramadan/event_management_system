class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all.order(:email)
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete your own account.'
      return
    end
    
    # Prevent deletion of the last admin
    if @user.admin? && User.admin.count <= 1
      redirect_to admin_users_path, alert: 'Cannot delete the last admin account.'
      return
    end
    
    if @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    else
      redirect_to admin_users_path, alert: 'Failed to delete user.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: 'User not found.'
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
