# frozen_string_literal: true

require 'common/client/configuration/rest'

module Mobile
  # Configuration for the Mobile::Auth::Service. A singleton class that returns
  # a connection that can make signed requests
  #
  # @example set the configuration in the service
  #   configuration Mobile::Auth::Configuration
  #
  class Configuration < Common::Client::Configuration::REST
    # Override the parent's base path
    # @return String the service base path from the environment settings
    #
    def base_path
      Settings.mobile_api.oauth_url
    end
    
    # Service name for breakers integration
    # @return String the service name
    #
    def service_name
      'MobileAuth'
    end
    
    # Faraday connection object with breakers, snakecase and json response middleware
    # @return Faraday::Connection connection to make http calls
    #
    def connection
      @connection ||= Faraday.new(
        base_path, headers: base_request_headers, request: request_options, ssl: ssl_options
      ) do |conn|
        conn.use :breakers
        conn.use Faraday::Response::RaiseError
        conn.response :snakecase
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
  end
end

