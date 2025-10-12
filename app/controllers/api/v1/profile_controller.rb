class Api::V1::ProfileController < Api::V1::BaseController
  before_action :ensure_attendee

  # GET /api/v1/profile
  def show
    user = @current_user
    render json: success_response(data: user.as_json(  include: {
         tickets: {
          only: [:id, :reference_code],
          methods: [:status_name]
        }
      })), status: :ok
  end
end