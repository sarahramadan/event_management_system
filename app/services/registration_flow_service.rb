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
    
    # Extract tickets data from response
    tickets_data = tickets_response[:data] || []
    
    # Update user phone number from first ticket if available
    if tickets_data.any? && tickets_data.first['phone_number'].present?
      @user.phone_number = tickets_data.first['phone_number']
    end
    
    # Map tickets
    tickets = []
    tickets_data.each do |ticket_data|
      ticket = map_tito_ticket_to_model(ticket_data)
      tickets << ticket
    end
    @user.tickets = tickets

    # Save user first
    if @user.save
        success_response(data: @user, status_code: :created)
    else
        error_response(errors: @user.errors.full_messages, status_code: :bad_request)
    end
  end

  private

  def map_tito_ticket_to_model(ticket_data)

    ticket_status = TicketStatus.find_by!(name: ticket_data['state'])
    
    # Create ticket with mapped data
    Ticket.new(
      reference_id: ticket_data['id'],
      reference_code: ticket_data['reference'],
      ticket_status: ticket_status,
      purchase_date: parse_tito_date(ticket_data['created_at']),
      release_name: ticket_data['release_title']
    )
  end

  def parse_tito_date(date_string)
    return nil if date_string.blank?
    
    begin
      DateTime.parse(date_string)
    rescue ArgumentError => e
      Rails.logger.warn("Could not parse date '#{date_string}': #{e.message}")
      nil
    end
  end
end