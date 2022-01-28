# frozen_string_literal: true

require 'fast_jsonapi'

module Mobile
  module V0
    class PaymentHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :payment_history
      attribute :payments
    end
  end
end