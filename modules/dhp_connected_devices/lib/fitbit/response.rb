require 'common/models/base'

module DhpConnectedDevices
  module Fitbit
    class Response < Common::Base
      def initialize(attributes = nil)
        super
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