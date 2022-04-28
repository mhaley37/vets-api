# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  class DiscoveryController < ApplicationController
    skip_before_action :authenticate

    def welcome
      render json: { data: { attributes: { message: 'Welcome to the mobile API' } } }
    end

    def token
      unless Settings.hostname != 'api.va.gov' && Flipper.enabled?(:mobile_api_test_sessions)
        raise Common::Exceptions::ResourceNotFound
      end

      raise_unauthorized('Missing Authorization header') if request.headers['Authorization'].nil?
      raise_unauthorized('Authorization header Bearer token is blank') if access_token.blank?

      token = Mobile::TestSessionHelper.new(access_token).find_or_create_session_token
      render json: {
        data: {
          attributes: {
            token: token
          }
        }
      }
    rescue JWT::DecodeError => e
      raise Common::Exceptions::Unauthorized.new(detail: e.message)
    end
  end
end
