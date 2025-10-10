class SessionsController < Devise::SessionsController
  # Override the create action to validate user role BEFORE authentication
  def create
    # Safely extract email from parameters
    email = params.dig(:user, :email)
    
    # Validate email presence
    unless email.present?
      redirect_to new_user_session_path, 
        alert: "Please provide an email address."
      return
    end
    
    # Check if user exists and validate their role before attempting authentication
    user = User.find_by(email: email.strip.downcase)
    
    if user&.attendee?
      # Prevent attendee users from logging in via web interface
      redirect_to new_user_session_path, 
        alert: "Web access is restricted for regular users. Please use our API for authentication: POST #{request.base_url}/api/v1/auth/login or visit #{request.base_url}/docs for documentation."
      return
    end
    
    # If user is admin or doesn't exist, proceed with normal Devise authentication
    super
  rescue StandardError => e
    Rails.logger.error "Login error: #{e.message}"
    redirect_to new_user_session_path, 
      alert: "An error occurred during login. Please try again."
  end

  protected

  # Override after_sign_in_path_for for admin users
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  # Override after_sign_out_path_for
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end