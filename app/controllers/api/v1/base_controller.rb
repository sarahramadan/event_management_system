class Api::V1::BaseController < ActionController::API
  include ExceptionHandler
  include ResponseHelper

  # Called before every action on controllers
  before_action :authorize_request

  attr_reader :current_user

  private

  # Check for valid request token and return user
  def authorize_request
    begin
      @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
    rescue StandardError => e
      response = error_response(errors: [e.message], status_code: :unauthorized)
      render json: response, status: response[:status_code]
    end
  end
 
  protected
  def ensure_attendee
    unless current_user&.attendee?
     render json: error_response(errors: [Message.access_denied_attendee], status_code: :forbidden), status: :forbidden
    end
  end

  # Standardized user response format for all API controllers
  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      confirmed: user.confirmed?,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end