class Api::V1::ProfileController < Api::V1::BaseController
  before_action :ensure_attendee

  # GET /api/v1/profile
  def show
    json_response({
      user: user_response(current_user)
    })
  end

  # PUT/PATCH /api/v1/profile
  def update
    if current_user.update(profile_params)
      json_response({
        message: Message.profile_updated,
        user: user_response(current_user)
      })
    else
      json_response({
        message: Message.profile_update_failed,
        errors: current_user.errors.full_messages
      }, :unprocessable_entity)
    end
  end

  # PUT /api/v1/profile/password
  def update_password
    if current_user.update_with_password(password_params)
      json_response({
        message: Message.password_updated
      })
    else
      json_response({
        message: Message.password_update_failed,
        errors: current_user.errors.full_messages
      }, :unprocessable_entity)
    end
  end

  # DELETE /api/v1/profile
  def destroy
    if current_user.destroy
      json_response({
        message: Message.account_deleted
      })
    else
      json_response({
        message: Message.account_deletion_failed,
        errors: current_user.errors.full_messages
      }, :unprocessable_entity)
    end
  end

  private

  def ensure_attendee
    unless current_user&.attendee?
      json_response({
        message: Message.access_denied_attendee
      }, :forbidden)
    end
  end

  def profile_params
    params.require(:user).permit(:name, :email)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end