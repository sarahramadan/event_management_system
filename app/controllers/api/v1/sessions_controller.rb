class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authorize_request, only: [:create]
  # POST /api/v1/auth/login
  def create
    authenticate_params = login_params
    
    # First check if user exists and is an attendee
    user = User.find_by(email: authenticate_params[:email])
    
    unless user&.attendee?
      return render json: error_response(
        errors: [Message.access_denied_attendee],
        status_code: :forbidden
      ), status: :forbidden
    end
    
    # Proceed with authentication
    auth_token = AuthenticateUser.new(authenticate_params[:email], authenticate_params[:password]).call

    render json: success_response(data: {
      token: auth_token,
      user: user_response(user)
    }), status: :ok
  end

  # DELETE /api/v1/auth/logout
  def destroy
    # Since JWT tokens are stateless, we'll just return success
    render json: success_response(data: {}), status: :ok
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end