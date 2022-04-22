# frozen_string_literal: true

require 'uri'
require 'configuration'

module Mobile
  module Auth
    # Class used to connect to Identity Oauth service which validates tokens
    # and given a valid token returns a set of user traits.
    #
    # @example create a new instance and call the introspect endpoint
    #   token = 'ypXeAwQedpmAy5xFD2u5'
    #   service = Mobile::Auth::Service.new
    #   response = service.post_introspect(token)
    #
    class Service < Common::Client::Base
      configuration Configuration

      # Validate a user's auth token and returns either valid active response with a set
      # of user traits or raise's an unauthorized error if the response comes back as invalid.
      #
      # @token String the auth token for the user
      #
      # @return Hash active user traits
      #
      def post_introspect(token)
        response = perform(
          :get, '/sign_in/introspect', nil, { 'Authorization' => "Bearer #{token}" }
        )
        response.body
      end
    end
  end
end
