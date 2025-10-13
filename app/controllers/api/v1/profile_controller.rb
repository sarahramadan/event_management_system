class Api::V1::ProfileController < Api::V1::BaseController
  before_action :ensure_attendee

  # GET /api/v1/profile
  def show
    user = @current_user
    render json: success_response(
    data: user.as_json.merge(
      tickets: user.tickets.map(&:ticket_summary)
    )
  ), status: :ok
  end
end