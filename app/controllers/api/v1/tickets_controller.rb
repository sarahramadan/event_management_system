class Api::V1::TicketsController < Api::V1::BaseController
  before_action :ensure_attendee

  # GET /api/v1/tickets/:id
  def show
    ticket = Ticket.find(params[:id])
    unless ticket.user_id == @current_user.id
      return render json: error_response(errors: [Message.access_denied], status_code: :forbidden), status: :forbidden
    end

    render json: success_response(data: ticket.ticket_summary), status: :ok
  end
end