require 'common/models/base'

module DhpConnectedDevices
  module Fitbit
    class Response < Common::Base
      def initialize(attributes = nil)
        super(attributes) if attributes
        self.status if attributes[:status]
        self.body if attributes[:body]
        parsed_body = JSON.parse(attributes[:body])
        self.data = parsed_body['data']
      end

      attribute :status, Integer
      attribute :body, String
      attribute :data, Object
    end
  end
end

Faraday::Response.register_middleware(fitbit_response: DhpConnectedDevices::Fitbit::Response)
