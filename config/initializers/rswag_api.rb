Rswag::Api.configure do |c|
  c.openapi_root = Rails.root.to_s + '/swagger'
  c.swagger_root = Rails.root.to_s + '/swagger'
  # Dynamically set host from environment
  c.swagger_filter = lambda do |swagger, env|
    swagger['host'] = Rails.application.routes.default_url_options[:host] || env['HTTP_HOST']
  end
end
