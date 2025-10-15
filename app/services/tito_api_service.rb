# frozen_string_literal: true

class TitoApiService < BaseService
  include HTTParty
  
  def initialize
    @base_url = Rails.application.credentials.tito&.dig(:base_url) || ENV['TITO_BASE_URL']
    @account_slug = Rails.application.credentials.tito&.dig(:account_slug) || ENV['TITO_ACCOUNT_SLUG']
    @event_slug = Rails.application.credentials.tito&.dig(:event_slug) || ENV['TITO_EVENT_SLUG']
    @api_token = Rails.application.credentials.tito&.dig(:api_token) || ENV['TITO_API_TOKEN']  
    validate_credentials!

    self.class.base_uri @base_url
    self.class.headers({
      'Authorization' => "Token token=#{@api_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    })
  end

  def find_tickets_by_attendee_email(email)
    response = make_request(:get, "/#{@account_slug}/#{@event_slug}/tickets?search[q]=#{email}")
    if response[:success] && response[:data]['tickets'].is_a?(Array) && response[:data]['tickets'].any?
      Rails.cache.write("tickets_#{email.downcase}", response[:data]['tickets'], expires_in: 1.hour)
      success_response(data: response[:data]['tickets'], status_code: response[:status_code])
    else
      error_response(errors: [Message.no_tickets_found], status_code: :not_found)
    end
  end

  def confirm_connection
    make_request(:get, "/hello")
  end
  
  def make_request(method, endpoint, options = {})
    retries = 0
    begin
      Rails.logger.info "Making #{method.upcase} request to Tito API: #{endpoint}"
      
      response = self.class.send(method, endpoint, options)

      Rails.logger.info "Tito API endpoint: #{endpoint} #{response.code}"
      Rails.logger.debug "Tito API response body: #{response}" if Rails.env.development?
      
      raise "Server error: #{response.code}" if (500..599).include?(response.code)

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
      else
        {
          success: false,
          status_code: response.code,
          error: 'Unexpected response',
          details: parse_response_body(response)
        }
      end
    rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, Errno::ECONNREFUSED, RuntimeError => e
      if retries < 3
        retries += 1
        wait_time = 2**retries
        Rails.logger.warn "Tito API request failed: #{e.message}. Retry #{retries} of 3. Waiting for #{wait_time} seconds."
        sleep wait_time
        retry
      end
      
      Rails.logger.error "Tito API request failed after 3 retries: #{e.message}"
      # Return an error response after final retry fails
      {
        success: false,
        status_code: 503, # Service Unavailable
        error: 'Service Unavailable - Cannot connect to Tito API after multiple attempts.'
      }
    end
  end
  
  def parse_response_body(response)
    return nil if response.body.blank?
    
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.warn "Failed to parse Tito1,AW API response as JSON: #{e.message}"
    response.body            
  end

  private   
  
  def validate_credentials!
    missing_credentials = []
    missing_credentials << 'account_slug' if @account_slug.blank?
    missing_credentials << 'event_slug' if @event_slug.blank?
    missing_credentials << 'api_token' if @api_token.blank?
    
    if missing_credentials.any?kk l    mmmmmmmm7--





      raise ArgumentError, "Missing Tito API credentials: #{missing_credentials.join(', ')}"
    end
  en22qq ..  