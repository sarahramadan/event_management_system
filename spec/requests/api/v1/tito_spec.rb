require 'swagger_helper'

RSpec.describe 'API V1 Tito', type: :request do
  # --------------------
  # Swagger/OpenAPI documentation
  # --------------------
  path '/api/v1/tito/test_connection' do
    get('Test Tito API connection') do
      tags 'Tito Integration'
      produces 'application/json'

      response(200, 'connection successful') do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 data: {
                   type: :object,
                   properties: {
                     message: { type: :string, example: 'Connection successful' }
                   }
                 }
               }
        run_test!
      end

      response(503, 'service unavailable') do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: false },
                 error: { type: :string, example: 'Service Unavailable' }
               }
        run_test!
      end
    end
  end

  path '/api/v1/tito/attendee_tickets' do
    get('Get attendee tickets from Tito') do
      tags 'Tito Integration'
      produces 'application/json'

      parameter name: :email, in: :query, type: :string, required: true, description: 'Email address to search for tickets'

      response(200, 'tickets found') do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, example: '123' },
                       reference: { type: :string, example: 'ABC123' },
                       email: { type: :string, example: 'john@example.com' },
                       name: { type: :string, example: 'John Doe' },
                       phone_number: { type: :string, example: '+1234567890' },
                       state_name: { type: :string, example: 'complete' }
                     }
                   }
                 }
               }
        run_test!
      end

      response(404, 'no tickets found') do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: false },
                 errors: { type: :array, items: { type: :string }, example: ['No tickets found for this email address'] }
               }
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: { message: { type: :string, example: 'Email parameter is required' } }
        run_test!
      end

      response(429, 'rate limited') do
        schema type: :object,
               properties: { success: { type: :boolean, example: false }, error: { type: :string, example: 'Rate Limited - Too many requests' } }
        run_test!
      end

      response(500, 'internal server error') do
        schema type: :object,
               properties: { success: { type: :boolean, example: false }, error: { type: :string, example: 'Internal Server Error' } }
        run_test!
      end

      response(503, 'service unavailable') do
        schema type: :object,
               properties: { error: { type: :string, example: 'Missing Tito API credentials: account_slug, event_slug' } }
        run_test!
      end
    end
  end

  # --------------------
  # Actual request specs
  # --------------------
  let(:tito_service) { instance_double(TitoApiService) }

  before do
    allow(TitoApiService).to receive(:new).and_return(tito_service)
  end

  describe "GET /api/v1/tito/test_connection" do
    context "when Tito API is accessible" do
      before do
        allow(tito_service).to receive(:test_connection).and_return({
          success: true,
          status_code: 200,
          data: { message: 'Connection successful' }
        })
      end

      it "returns successful connection response" do
        get "/api/v1/tito/test_connection"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including('message' => 'Connection successful')
        )
      end
    end

    context "when Tito API is not accessible" do
      before do
        allow(tito_service).to receive(:test_connection).and_return({
          success: false,
          status_code: 503,
          error: 'Service Unavailable'
        })
      end

      it "returns service unavailable response" do
        get "/api/v1/tito/test_connection"

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'Service Unavailable'
        )
      end
    end

    context "when Tito API credentials are missing" do
      before do
        allow(TitoApiService).to receive(:new).and_raise(ArgumentError, "Missing Tito API credentials: api_token")
      end

      it "returns service unavailable with error message" do
        get "/api/v1/tito/test_connection"

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to include(
          'error' => 'Missing Tito API credentials: api_token'
        )
      end
    end
  end

  describe "GET /api/v1/tito/attendee_tickets" do
    let(:email) { 'john@example.com' }
    let(:tickets_data) do
      [
        { 'id' => '123', 'reference' => 'ABC123', 'email' => email, 'name' => 'John Doe', 'phone_number' => '+1234567890', 'state_name' => 'complete' },
        { 'id' => '124', 'reference' => 'ABC124', 'email' => email, 'name' => 'John Doe', 'phone_number' => '+1234567890', 'state_name' => 'incomplete' }
      ]
    end

    context "with valid email parameter" do
      before do
        allow(tito_service).to receive(:find_tickets_by_attendee_email)
          .with(email)
          .and_return({ success: true, status_code: 200, data: tickets_data })
      end

      it "returns tickets for the specified email" do
        get "/api/v1/tito/attendee_tickets", params: { email: email }

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to include('success' => true, 'data' => be_an(Array))
        expect(body['data'].size).to eq(2)
        expect(body['data'].first).to include('id' => '123', 'email' => email, 'name' => 'John Doe')
      end
    end

    context "when no tickets found for email" do
      before do
        allow(tito_service).to receive(:find_tickets_by_attendee_email)
          .with(email)
          .and_return({ success: false, status_code: 404, errors: ['No tickets found for this email address'] })
      end

      it "returns not found response" do
        get "/api/v1/tito/attendee_tickets", params: { email: email }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('success' => false, 'errors' => ['No tickets found for this email address'])
      end
    end

    context "without email parameter" do
      it "returns bad request" do
        get "/api/v1/tito/attendee_tickets"

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('message')
      end
    end

    context "when Tito API returns error" do
      before do
        allow(tito_service).to receive(:find_tickets_by_attendee_email)
          .with(email)
          .and_return({ success: false, status_code: 500, error: 'Internal Server Error' })
      end

      it "returns internal server error" do
        get "/api/v1/tito/attendee_tickets", params: { email: email }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to include('success' => false, 'error' => 'Internal Server Error')
      end
    end

    context "with rate limiting" do
      before do
        allow(tito_service).to receive(:find_tickets_by_attendee_email)
          .with(email)
          .and_return({ success: false, status_code: 429, error: 'Rate Limited - Too many requests' })
      end

      it "returns rate limited response" do
        get "/api/v1/tito/attendee_tickets", params: { email: email }

        expect(response).to have_http_status(:too_many_requests)
        expect(JSON.parse(response.body)).to include('success' => false, 'error' => 'Rate Limited - Too many requests')
      end
    end

    context "when Tito API credentials are missing" do
      before do
        allow(TitoApiService).to receive(:new).and_raise(ArgumentError, "Missing Tito API credentials: account_slug, event_slug")
      end

      it "returns service unavailable with error message" do
        get "/api/v1/tito/attendee_tickets", params: { email: email }

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to include('error' => 'Missing Tito API credentials: account_slug, event_slug')
      end
    end
  end
end
