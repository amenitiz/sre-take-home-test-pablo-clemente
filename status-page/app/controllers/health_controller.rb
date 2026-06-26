class HealthController < ApplicationController
  def show
    checks = {
      database: database_connected?,
      timestamp: Time.current.iso8601
    }

    status = checks[:database] ? :ok : :service_unavailable
    render json: checks, status: status
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end
end
