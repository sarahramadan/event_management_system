# spec/requests/api/v1/registrations_spec.rb
require 'rails_helper'

RSpec.describe 'API V1 Registrations', type: :request do
  let(:valid_attributes) do
    {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      phone_number: '+1234567890'
    }
  end

  let(:tito_service) { instance_double(TitoApiService) }
  let(:registration_service) { instance_double(RegistrationFlowService) }

  before do
    allow(TitoApiService).to receive(:new).and_return(tito_service)
    allow(RegistrationFlowService).to receive(:new).and_return(registration_service)
  end

  describe 'POST /api/v1/register' do
    context 'with valid parameters and existing tickets' do
      before do
        allow(registration_service).to receive(:start_registration).and_return({
          success: true,
          status_code: 201,
          data: build(:user, valid_attributes)
        })
      end

      it 'creates a new user and returns success response' do
        expect {
          post '/api/v1/register', params: valid_attributes
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body).to include(
          'message' => 'Registration successful',
          'user' => hash_including(
            'email' => 'john@example.com',
            'name' => 'John Doe'
          )
        )
      end
    end

    context 'when user has no tickets in Tito' do
      before do
        allow(registration_service).to receive(:start_registration).and_return({
          success: false,
          status_code: 404,
          errors: ['No tickets found for this email address']
        })
      end

      it 'returns not found error' do
        post '/api/v1/register', params: valid_attributes

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          'errors' => ['No tickets found for this email address']
        )
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for missing email' do
        invalid_params = valid_attributes.except(:email)
        post '/api/v1/register', params: invalid_params
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when Tito API is unavailable' do
      before do
        allow(TitoApiService).to receive(:new).and_raise(ArgumentError, 'Missing Tito API credentials')
      end

      it 'returns service unavailable error' do
        post '/api/v1/register', params: valid_attributes
        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to include(
          'error' => 'Missing Tito API credentials'
        )
      end
    end
  end
end
