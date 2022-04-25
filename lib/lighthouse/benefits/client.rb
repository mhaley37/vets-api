# frozen_string_literal: true

require 'lighthouse/benefits/configuration'
require 'lighthouse/benefits/jwt_wrapper'

# This client was written to work for the specific use case of the
# VA OCTO's hypertension fast track pilot, which is located in a Sidekiq job that is kicked off
# one-to-one for each veteran 526 claim for increase submitted in va.gov
module Lighthouse
  module Benefits
    # Documentation located at:
    # https://developer.va.gov/explore/benefits/docs/fhir?version=current
    class Client < Common::Client::Base
      include Common::Client::Concerns::Monitoring
      configuration Lighthouse::Benefits::Configuration

      # Handles the Lighthouse request for the passed-in resource.
      # Returns the entire collection of paged data in a single response.
      #
      # @example
      #
      # list_resource('observations')
      #
      # @param [String] resource The Lighthouse resource being requested
      #
      # @return Faraday::Env response
      def list_resource(resource)
        resource = resource.downcase
        raise ArgumentError, 'unsupported resource type' unless %w[claims].include?(resource)

        send("list_#{resource}")
      end

      def list_claims(ssn: '', first_name: nil, last_name: nil, iso8601_dob: nil)
        params = {
        }
        uri_path = 'services/claims/v1/claims'
        params_headers_hash = headers_hash.merge({
                                                   'X-VA-SSN' => ssn,
                                                   'X-VA-First-Name' => first_name,
                                                   'X-VA-Last-Name' => last_name,
                                                   'X-VA-Birth-Date' => iso8601_dob
                                                 })
        perform(:get, uri_path, params, params_headers_hash)
      end

      private

      def authenticate(params)
        perform(
          :post,
          'oauth2/claims/system/v1/token',
          URI.encode_www_form(params),
          { 'Content-Type': 'application/x-www-form-urlencoded' }
        )
      end

      def bearer_token
        @bearer_token ||= retrieve_bearer_token
      end

      def headers_hash
        @headers_hash ||= Configuration.base_request_headers.merge({ Authorization: "Bearer #{bearer_token}" })
      end

      def retrieve_bearer_token
        authenticate_as_system(JwtWrapper.new.token)
      end

      def authenticate_as_system(json_web_token)
        authenticate(payload(json_web_token)).body['access_token']
      end

      def payload(json_web_token)
        {
          grant_type: 'client_credentials',
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: json_web_token,
          scope: Settings.lighthouse.benefits.fast_tracker.api_scope.join(' ')
        }.as_json
      end
    end
  end
end
