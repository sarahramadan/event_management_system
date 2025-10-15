require 'swagger_helper'

RSpec.describe 'API V1 Profile', type: :request do
  path '/api/v1/profile' do
    get('Get user profile') do
      tags 'Profile'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'john@example.com' },
                     name: { type: :string, example: 'John Doe' },
                     phone_number: { type: :string, example: '+1234567890' },
                     role: { type: :string, example: 'attendee' }
                   }
                 },
                 tickets: {
                   type: :array,
                   items: {
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
                       }
                     }
                   }
                 }
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

  # --- Actual request specs below ---

  let(:user) { create(:user, :with_tickets) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /api/v1/profile" do
    context "with valid authentication" do
      it "returns user profile with tickets" do
        get "/api/v1/profile", headers: headers

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)

        expect(response_body).to include(
          'user' => hash_including(
            'id' => user.id,
            'email' => user.email,
            'name' => user.name,
            'phone_number' => user.phone_number,
            'role' => user.role
          ),
          'tickets' => be_an(Array)
        )

        if user.tickets.any?
          ticket = response_body['tickets'].first
          expect(ticket).to include(
            'id',
            'reference_id',
            'email',
            'name',
            'phone_number'
          )
        end
      end

      it "includes ticket status information" do
        get "/api/v1/profile", headers: headers

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)

        if response_body['tickets'].any?
          ticket = response_body['tickets'].first
          expect(ticket).to include('ticket_status')
          expect(ticket['ticket_status']).to include('name')
        end
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/profile"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include('message')
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/profile", headers: { 'Authorization' => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with expired token" do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }

      it "returns unauthorized" do
        get "/api/v1/profile", headers: { 'Authorization' => "Bearer #{expired_token}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is deleted" do
      it "returns unauthorized" do
        user.destroy

        get "/api/v1/profile", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
