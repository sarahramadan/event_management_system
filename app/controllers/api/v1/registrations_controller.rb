class Api::V1::RegistrationsController < Api::V1::BaseController
  skip_before_action :authorize_request, only: [:create]

  # POST /api/v1/attendees/register
  def create
    user = User.new(user_params)
    user.role = :attendee

    # Validate presence and format before Devise tries to save
    validation_errors = validate_registration_params(user_params)
    if validation_errors.any?
      return render json: error_response(errors: validation_errors ,status_code: :bad_request), status: :bad_request
    end

    registration_service = RegistrationFlowService.new(user)
    result = registration_service.start_registration
    render json: result, status: result[:status_code]

  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # validate user input before registration
  def validate_registration_params(params)
    errors = []

    # Basic structure validation
    errors << 'Name is required' if params[:name].blank?
    errors << 'Email is required' if params[:email].blank?
    errors << 'Password is required' if params[:password].blank?

    # Email format validation
    if params[:email].present? &&
       !(params[:email] =~ URI::MailTo::EMAIL_REGEXP)
      errors << 'Email format is invalid'
    end

    errors
  end
end