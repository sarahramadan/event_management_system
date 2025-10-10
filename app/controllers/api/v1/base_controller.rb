class Api::V1::BaseController < ActionController::API
  include ExceptionHandler

  # Called before every action on controllers
  before_action :authorize_request
  
  attr_reader :current_user

  private

  # Check for valid request token and return user
  def authorize_request
    begin
      @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
    rescue StandardError => e
      json_response({ message: Message.unauthorized, error: e.message }, :unauthorized)
    end
  end

  def json_response(object, status = :ok)
    render json: object, status: status
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