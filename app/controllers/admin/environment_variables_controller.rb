class Admin::EnvironmentVariablesController < ApplicationController
  # This controller is intended for development environment debugging ONLY.
  # It exposes sensitive configuration values and should not be used in production.
  before_action :ensure_development_env

def show
  @variables = {
    DEVELOPMENT_HOSTS: ENV['DEVELOPMENT_HOSTS'],
    TITO_BASE_URL: ENV['TITO_BASE_URL'],
    TITO_ACCOUNT_SLUG: ENV['TITO_ACCOUNT_SLUG'],
    TITO_EVENT_SLUG: ENV['TITO_EVENT_SLUG'],
    TITO_API_TOKEN: ENV['TITO_API_TOKEN'],
    TITO_WEBHOOK_SECRET: ENV['TITO_WEBHOOK_SECRET']
  }
end

  private

  def ensure_development_env
    return if Rails.env.development?

    respond_to do |format|
      format.html { redirect_to admin_root_path, alert: 'Page not found' }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
    end
  end
end
