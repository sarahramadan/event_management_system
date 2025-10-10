class AdminRegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :check_admin_registration_allowed, only: [:new, :create]

  # GET /admin/sign_up
  def new
    @user = User.new
    @user.role = :admin
  end

  # POST /admin/sign_up
  def create
    @user = User.new(user_params)
    @user.role = :admin
    
    if @user.save
      sign_in(@user)
      redirect_to admin_root_path, notice: 'Admin account created successfully. Please check your email to confirm your account.'
    else
      flash.now[:alert] = 'Please correct the errors below.'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def check_admin_registration_allowed
    unless User.admin_registration_allowed?
      flash[:alert] = "Admin registration is currently limited. Please contact the system administrator."
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  rescue ActionController::ParameterMissing => e
    flash.now[:alert] = "Missing required parameter: #{e.param}"
    redirect_to new_admin_registration_path and return
  end
end