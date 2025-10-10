class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authorize_request, only: [:create]

  # POST /api/v1/auth/login
  def create
    authenticate_params = login_params
    auth_token = AuthenticateUser.new(authenticate_params[:email], authenticate_params[:password]).call
    
    user = User.find_by(email: authenticate_params[:email])
    
    json_response({
      message: Message.login_successful,
      token: auth_token,
      user: user_response(user)
    })
  end

  # DELETE /api/v1/auth/logout
  def destroy
    # Since JWT tokens are stateless, we'll just return success
    # In a production app, you might want to blacklist tokens
    json_response({
      message: Message.logged_out_successfully
    })
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end