class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show]

  def index
    @users = User.all.order(:email)
  end

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
