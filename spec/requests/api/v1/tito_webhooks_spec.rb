require 'swagger_helper'

RSpec.describe 'API V1 Tito Webhooks', type: :request do
  path '/api/v1/webhook' do
    post('Receive Tito webhook') do
      tags 'Webhooks'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'X-Webhook-Signature', in: :header, type: :string, description: 'Webhook signature for verification'
      parameter name: :webhook_data, in: :body, schema: {
        type: :object,
        properties: {
          webhook: {
            type: :object,
            properties: {
              url: { type: :string, example: 'https://api.tito.io/webhooks/123' }
            }
          },
          ticket: {
            type: :object,
            properties: {
              id: { type: :string, example: 'abc123' },
              reference: { type: :string, example: 'REF123' },
              slug: { type: :string, example: 'ref123' },
              email: { type: :string, example: 'john@example.com' },
              name: { type: :string, example: 'John Doe' },
              phone_number: { type: :string, example: '+1234567890' },
              state_name: { type: :string, example: 'complete' }
            }
          }
        },
        required: ['webhook', 'ticket']
      }

      response(200, 'webhook processed successfully') do
        schema type: :object,
               properties: { message: { type: :string, example: 'Webhook processed successfully' } }
        run_test!
      end

      response(401, 'invalid signature') do
        schema type: :object,
               properties: { message: { type: :string, example: 'Invalid webhook signature' } }
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: { message: { type: :string, example: 'Invalid JSON payload' } }
        run_test!
      end

      response(422, 'processing failed') do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string }, example: ['Processing failed'] }
               }
        run_test!
      end
    end
  end

  # ↓ All normal RSpec setup stays inside same describe block
  let(:webhook_secret) { ENV['TITO_WEBHOOK_SECRET'] || 'test_secret' }
  let(:valid_payload) do
    {
      webhook: { url: "https://api.tito.io/webhooks/123" },
      ticket: {
        id: "abc123", reference: "REF123", slug: "ref123",
        email: "john@example.com", name: "John Doe",
        phone_number: "+1234567890", state_name: "complete"
      }
    }
  end

  def generate_signature(payload, secret)
    'sha256=' + OpenSSL::HMAC.hexdigest('sha256', secret, payload)
  end

  describe "POST /api/v1/webhook" do
    context "with valid signature and payload" do
      let(:payload_json) { valid_payload.to_json }
      let(:signature) { generate_signature(payload_json, webhook_secret) }

      it "processes ticket creation webhook successfully" do
        post "/api/v1/webhook",
             params: payload_json,
             headers: {
               'Content-Type' => 'application/json',
               'X-Webhook-Signature' => signature
             }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'message' => 'Webhook processed successfully'
        )
      end

      it "creates or updates ticket in database" do
        expect {
          post "/api/v1/webhook",
               params: payload_json,
               headers: {
                 'Content-Type' => 'application/json',
                 'X-Webhook-Signature' => signature
               }
        }.to change(Ticket, :count).by(1)

        ticket = Ticket.find_by(tito_id: valid_payload[:ticket][:id])
        expect(ticket).to be_present
        expect(ticket.email).to eq(valid_payload[:ticket][:email])
        expect(ticket.name).to eq(valid_payload[:ticket][:name])
      end

      it "updates existing ticket if already exists" do
        existing_ticket = create(:ticket, tito_id: valid_payload[:ticket][:id])
        
        expect {
          post "/api/v1/webhook",
               params: payload_json,
               headers: {
                 'Content-Type' => 'application/json',
                 'X-Webhook-Signature' => signature
               }
        }.not_to change(Ticket, :count)

        existing_ticket.reload
        expect(existing_ticket.email).to eq(valid_payload[:ticket][:email])
      end
    end

    context "with invalid signature" do
      let(:payload_json) { valid_payload.to_json }

      it "returns unauthorized" do
        post "/api/v1/webhook",
             params: payload_json,
             headers: {
               'Content-Type' => 'application/json',
               'X-Webhook-Signature' => 'sha256=invalid_signature'
             }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include(
          'message' => 'Invalid webhook signature'
        )
      end
    end

    context "without signature header" do
      it "returns unauthorized" do
        post "/api/v1/webhook",
             params: valid_payload.to_json,
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with malformed JSON payload" do
      let(:invalid_payload) { "{ invalid json }" }
      let(:signature) { generate_signature(invalid_payload, webhook_secret) }

      it "returns bad request" do
        post "/api/v1/webhook",
             params: invalid_payload,
             headers: {
               'Content-Type' => 'application/json',
               'X-Webhook-Signature' => signature
             }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with missing required ticket data" do
      let(:incomplete_payload) { { webhook: { url: "..." }, ticket: { id: "abc123" } } }
      let(:payload_json) { incomplete_payload.to_json }
      let(:signature) { generate_signature(payload_json, webhook_secret) }

      it "returns bad request for missing data" do
        post "/api/v1/webhook",
             params: payload_json,
             headers: {
               'Content-Type' => 'application/json',
               'X-Webhook-Signature' => signature
             }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "webhook processing errors" do
      let(:payload_json) { valid_payload.to_json }
      let(:signature) { generate_signature(payload_json, webhook_secret) }

      before do
        allow_any_instance_of(TitoWebhookService).to receive(:process_webhook)
          .and_return({
            success: false,
            status_code: 422,
            errors: ['Processing failed']
          })
      end

      it "returns error response when processing fails" do
        post "/api/v1/webhook",
             params: payload_json,
             headers: {
               'Content-Type' => 'application/json',
               'X-Webhook-Signature' => signature
             }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ['Processing failed']
        )
      end
    end
  end
end
