# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  class DiscoveryController < ApplicationController
    skip_before_action :authenticate

    def welcome
      render json: { data: { attributes: { message: 'Welcome to the mobile API' } } }
    end

    def token
      return nil unless Settings.hostname != 'api.va.gov' && Flipper.enabled?(:mobile_api_tests)

      token = Mobile::TestSessionHelper.new(access_token).find_or_create_session_token
      render json: {
        data: {
          attributes: {
            token: token
          }
        }
      }
    end
  end
end
