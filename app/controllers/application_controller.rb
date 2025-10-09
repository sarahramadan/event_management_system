class ApplicationController < ActionController::Base
  # Ensure user is authenticated for all actions unless explicitly skipped
  before_action :authenticate_user!
  
  # Configure strong parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Helper method to require admin access
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end


  # Check if current user is admin
  def current_user_admin?
    current_user&.admin?
  end
  helper_method :current_user_admin?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end
end
