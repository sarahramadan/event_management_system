class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_action :authorize_request, only: [:create]

  # POST /api/v1/attendees/register
  def create
    user = User.new(user_params)
    user.role = :attendee

    if user.save
      # Generate JWT token for the user
      token = JsonWebToken.encode(user_id: user.id)
      
      json_response({
        message: Message.account_created,
        token: token,
        user: user_response(user)
      }, :created)
    else
      json_response({
        message: Message.account_not_created,
        errors: user.errors.full_messages
      }, :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end