require 'openssl'
require 'base64'

class Api::V1::TitoWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :verify_tito_signature!

  def receive
    data = JSON.parse(request.raw_post)
    event_type = request.headers['HTTP_X_WEBHOOK_NAME']

    case event_type
    when 'ticket.updated', 'ticket.created'
      TicketSyncService.new(data).ticket_sync
    when 'registration.updated', 'registration.completed'
      TicketSyncService.new(data).user_sync
    else
      Rails.logger.info "Unhandled Tito event: #{event_type}"
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Webhook JSON parse error: #{e.message}"
    head :bad_request
  end

  private

  def verify_tito_signature!
    puts "=== HEADERS START ==="
    request.headers.each { |k, v| puts "#{k}: #{v}" if k.start_with?('HTTP_') }
    puts "=== HEADERS END ==="
    puts "Verifying Tito signature"
    raw_payload = request.raw_post
    puts "Raw payload: #{raw_payload}"
    secret = Rails.application.credentials.tito&.dig(:webhook_secret) || ENV['TITO_WEBHOOK_SECRET']
    puts "Secret: #{secret}"

    unless valid_signature?(raw_payload, secret)
      Rails.logger.error "Invalid Tito signature — request not trusted"
      head :unauthorized and return
    end
  end

  def valid_signature?(payload, secret)
    return false if secret.blank?

    signature_header = request.headers['HTTP_TITO_SIGNATURE']
    puts "Signature header: #{signature_header.inspect}"
    expected_signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256') , secret, payload)).strip
    puts "Expected signature: #{expected_signature.inspect}"

    # Prevent timing attacks
    ActiveSupport::SecurityUtils.secure_compare(
      expected_signature,
      signature_header.strip
    )
  end
end
