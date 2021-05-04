# frozen_string_literal: true

require 'common/client/configuration/rest'
require 'common/client/middleware/response/gids_errors'
require 'common/client/middleware/response/json_parser'
require 'common/client/middleware/response/raise_error'
require 'common/client/middleware/response/snakecase'

module GI
  module V1
    class Configuration < Common::Client::Configuration::REST
      self.read_timeout = Settings.gids.read_timeout || 1
      self.open_timeout = Settings.gids.open_timeout || 1

      def base_path
        "#{Settings.gids.url}/v1/"
      end

      def service_name
        'GI'
      end

      def connection
        Faraday.new(base_path, headers: base_request_headers, request: request_options) do |conn|
          conn.use :breakers
          conn.request :json
          # Uncomment this out for generating curl output
          # conn.request :curl, ::Logger.new(STDOUT), :warn

          # conn.response :logger, ::Logger.new(STDOUT), bodies: true
          conn.response :snakecase
          conn.response :raise_error, error_prefix: service_name
          conn.response :gids_errors
          conn.response :json_parser

          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
