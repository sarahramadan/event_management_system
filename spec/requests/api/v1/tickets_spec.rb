require 'swagger_helper'

RSpec.describe 'API V1 Tickets', type: :request do
  # --------------------
  # Swagger/OpenAPI documentation
  # --------------------
  path '/api/v1/tickets/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Ticket ID'

    get('Get ticket details') do
      tags 'Tickets'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 ticket: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     reference_id: { type: :string, example: 'ABC123' },
                     email: { type: :string, example: 'john@example.com' },
                     name: { type: :string, example: 'John Doe' },
                     phone_number: { type: :string, example: '+1234567890' },
                     state_name: { type: :string, example: 'complete' },
                     ticket_status: {
                       type: :object,
                       properties: {
                         id: { type: :integer, example: 1 },
                         name: { type: :string, example: 'Confirmed' }
                       }
                     },
                     user: {
                       type: :object,
                       properties: {
                         id: { type: :integer, example: 1 },
                         email: { type: :string, example: 'john@example.com' },
                         name: { type: :string, example: 'John Doe' }
                       }
                     }
                   }
                 }
               }

        run_test!
      end

      response(404, 'ticket not found') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Ticket not found' }
               }
        run_test!
      end

      response(401, 'unauthorized') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Unauthorized' }
               }
        run_test!
      end
    end
  end

  # --------------------
  # Actual request specs
  # --------------------
  let(:user) { create(:user, :with_tickets) }
  let(:other_user) { create(:user, :with_tickets) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:ticket) { user.tickets.first }
  let(:other_ticket) { other_user.tickets.first }

  describe "GET /api/v1/tickets/:id" do
    context "with valid authentication and own ticket" do
      it "returns ticket details" do
        get "/api/v1/tickets/#{ticket.id}", headers: headers

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include(
          'ticket' => hash_including(
            'id' => ticket.id,
            'reference_id' => ticket.reference_id,
            'email' => ticket.email,
            'name' => ticket.name,
            'phone_number' => ticket.phone_number,
            'state_name' => ticket.state_name
          )
        )
      end

      it "includes ticket status information" do
        get "/api/v1/tickets/#{ticket.id}", headers: headers
        response_body = JSON.parse(response.body)

        expect(response_body['ticket']).to include(
          'ticket_status' => hash_including(
            'id' => ticket.ticket_status.id,
            'name' => ticket.ticket_status.name
          )
        )
      end

      it "includes user information" do
        get "/api/v1/tickets/#{ticket.id}", headers: headers
        response_body = JSON.parse(response.body)

        expect(response_body['ticket']).to include(
          'user' => hash_including(
            'id' => user.id,
            'email' => user.email,
            'name' => user.name
          )
        )
      end
    end

    context "when trying to access another user's ticket" do
      it "returns not found" do
        get "/api/v1/tickets/#{other_ticket.id}", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          'message' => 'Ticket not found'
        )
      end
    end

    context "when ticket doesn't exist" do
      it "returns not found" do
        get "/api/v1/tickets/99999", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          'message' => 'Ticket not found'
        )
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/tickets/#{ticket.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/tickets/#{ticket.id}", headers: { 'Authorization' => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "Admin access scenarios" do
    let(:admin_user) { create(:user, :admin) }
    let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }
    let(:admin_headers) { { 'Authorization' => "Bearer #{admin_token}" } }

    context "when admin accesses any ticket" do
      it "allows access to any user's ticket" do
        get "/api/v1/tickets/#{ticket.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['ticket']['id']).to eq(ticket.id)
      end
    end
  end
end
