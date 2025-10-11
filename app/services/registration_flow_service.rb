class RegistrationFlowService < BaseService
  def initialize(user)
    @user = user
    @tito_service = TitoApiService.new
  end
   
  def start_registration
    # Send request to Tito API to check if user has tickets
    tickets_response = @tito_service.find_tickets_by_attendee_email(@user.email)
    
    # If no tickets found, return error response
    unless tickets_response[:success]
      return tickets_response
    end
    
    # Proceed with registration flow if tickets are found
    if @user.save
      # Generate JWT token for the user
      token = JsonWebToken.encode(user_id: @user.id)
      success_response(data: { token: token }, status_code: :created)
    else
      error_response(errors: @user.errors.full_messages, status_code: :bad_request)
    end
  end
end