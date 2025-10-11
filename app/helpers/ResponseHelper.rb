module ResponseHelper
  extend ActiveSupport::Concern

  def success_response(data: {}, status_code: :ok)
    return {
      success: true,
      status_code: resolve_status_code(status_code),
      data: data
    }
  end

  def error_response(errors: [], status_code: :bad_request)
    return {
      success: false,
      errors: Array(errors),
      status_code: resolve_status_code(status_code),
    }
  end

  def resolve_status_code(status_code)
    puts "Resolving status code for: #{status_code.inspect} #{status_code}"
    if status_code.is_a?(Integer)
      status_code
    elsif status_code.respond_to?(:to_sym)
      Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code.to_sym]
    else
      500
    end
  end
end