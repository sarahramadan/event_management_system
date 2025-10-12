# frozen_string_literal: true

class TitoApiService < BaseService
  include HTTParty
  
  def initialize
    @base_url = Rails.application.credentials.tito&.dig(:base_url) || ENV['TITO_BASE_URL']
    @account_slug = Rails.application.credentials.tito&.dig(:account_slug) || ENV['TITO_ACCOUNT_SLUG']
    @event_slug = Rails.application.credentials.tito&.dig(:event_slug) || ENV['TITO_EVENT_SLUG']
    @api_token = Rails.application.credentials.tito&.dig(:api_token) || ENV['TITO_API_TOKEN']  
    puts "sarah: #{@base_url}, #{@account_slug}, #{@event_slug}, #{@api_token}"
    validate_credentials!

    self.class.base_uri @base_url
    self.class.headers({
      'Authorization' => "Token token=#{@api_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    })
  end

  def find_tickets_by_attendee_email(email)
    # Retrieve from cache if available
    cached_tickets = Rails.cache.read("tickets_#{email.downcase}")
    if cached_tickets.present?
      puts "read cached tickets for #{email} #{cached_tickets}"
      return success_response(data: cached_tickets, status_code: :ok)
    end

    response = make_request(:get, "/#{@account_slug}/#{@event_slug}/tickets?search[q]=#{email}")
    # Check if tickets array is not empty then cached and return tickets
    if response[:success] && response[:data]['tickets'].is_a?(Array) && response[:data]['tickets'].any?
      Rails.cache.write("tickets_#{email.downcase}", response[:data]['tickets'], expires_in: 1.hour)
      puts "write cached  #{email}"
      success_response(data: response[:data]['tickets'], status_code: response[:status_code])
    else
      error_response(errors: [Message.no_tickets_found], status_code: :not_found)
    end
  end

  # Test API connection
  def confirm_connection
    make_request(:get, "/hello")
  end

  def test_connection
    response = confirm_connection
  end
  
  private
  
  def validate_credentials!
    missing_credentials = []
    missing_credentials << 'account_slug' if @account_slug.blank?
    missing_credentials << 'event_slug' if @event_slug.blank?
    missing_credentials << 'api_token' if @api_token.blank?
    
    if missing_credentials.any?
      raise ArgumentError, "Missing Tito API credentials: #{missing_credentials.join(', ')}"
    end
  end
  
  def make_request(method, endpoint, options = {})
    Rails.logger.info "Making #{method.upcase} request to Tito API: #{endpoint}"
    
    response = self.class.send(method, endpoint, options)

    Rails.logger.info "Tito API endpoint: #{endpoint} #{response.code}"
    Rails.logger.debug "Tito API response body: #{response}" if Rails.env.development?
    
    case response.code
    when 200..299
      {
        success: true,
        status_code: response.code,
        data: parse_response_body(response),
      }
    when 400
      {
        success: false,
        status_code: response.code,
        error: 'Bad Request - Invalid parameters',
        details: parse_response_body(response)
      }
    when 401
      {
        success: false,
        status_code: response.code,
        error: 'Unauthorized - Invalid API token',
        details: parse_response_body(response)
      }
    when 403
      {
        success: false,
        status_code: response.code,
        error: 'Forbidden - Insufficient permissions',
        details: parse_response_body(response)
      }
    when 404
      {
        success: false,
        status_code: response.code,
        error: 'Not Found - Resource does not exist',
        details: parse_response_body(response)
      }
    when 422
      {
        success: false,
        status_code: response.code,
        error: 'Unprocessable Entity - Validation errors',
        details: parse_response_body(response)
      }
    when 429
      {
        success: false,
        status_code: response.code,
        error: 'Rate Limited - Too many requests',
        details: parse_response_body(response)
      }
    when 500..599
      {
        success: false,
        status_code: response.code,
        error: 'Server Error - Tito API is experiencing issues',
        details: parse_response_body(response)
      }
    else
      {
        success: false,
        status_code: response.code,
        error: 'Unexpected response',
        details: parse_response_body(response)
      }
    end
  rescue Net::TimeoutError
    {
      success: false,
      status_code: 408,
      error: 'Request Timeout - Tito API did not respond in time'
    }
  rescue SocketError, Errno::ECONNREFUSED
    {
      success: false,
      status_code: 503,
      error: 'Service Unavailable - Cannot connect to Tito API'
    }
  rescue StandardError => e
    Rails.logger.error "Tito API request failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
    
    {
      success: false,
      status_code: 500,
      error: "Unexpected error: #{e.message}"
    }
  end
  
  def parse_response_body(response)
    return nil if response.body.blank?
    
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.warn "Failed to parse Tito API response as JSON: #{e.message}"
    response.body
  end
end