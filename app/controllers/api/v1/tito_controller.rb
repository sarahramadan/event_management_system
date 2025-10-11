# frozen_string_literal: true

class Api::V1::TitoController < Api::V1::BaseController
  skip_before_action :authorize_request, only: [:test_connection, :attendee_tickets]
  before_action :initialize_tito_service
  # before_action :authenticate_user!
  
  # GET /api/v1/tito/test_connection
  def test_connection
    result = @tito_service.test_connection
    
    render json: result, status: result[:status_code]
  end
  
  #GET /api/v1/tito/attendee_tickets
  def attendee_tickets  
    email = params[:email]
    puts "sarah: email param is #{email}"
    response = @tito_service.find_tickets_by_attendee_email(email)
    render json: response, status: response[:status_code]
  end

  private
  
  def initialize_tito_service
    @tito_service = TitoApiService.new
  rescue ArgumentError => e
    render json: {
      message: Message.api_error,
      error: e.message
    }, status: :service_unavailable
  end
end