# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class OAuthController < ApplicationController
    include Warden::GitHub::SSO

    before_action :authenticate!, only: [:index]
    before_action :authorize!, only: [:index]

    def index
      redirect_to "#{url}/signin"
    end

    def unauthorized
      head :unauthorized
    end

    def is_authorized
      render json: @current_user if authorized?
    end

    def logout
      warden.logout(:tud)
      redirect_to url
    end

    private

    def url
      return 'https://tud.vfs.va.gov' if Settings.vsp_environment == 'staging'
      'http://localhost:8000'
    end
  end
end
