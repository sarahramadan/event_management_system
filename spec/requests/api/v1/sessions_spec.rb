require 'swagger_helper'

RSpec.describe 'API V1 Sessions', type: :request do
  path '/api/v1/auth/login' do
    post('Login user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response(200, 'successful login') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Login successful' },
                 token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'user@example.com' },
                     name: { type: :string, example: 'John Doe' },
                     role: { type: :string, example: 'attendee' }
                   }
                 }
               }

        run_test!
      end

      response(401, 'unauthorized') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Invalid credentials' }
               }
        run_test!
      end

      response(400, 'bad request') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Email and password are required' }
               }
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete('Logout user') do
      tags 'Authentication'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful logout') do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Logout successful' }
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
end