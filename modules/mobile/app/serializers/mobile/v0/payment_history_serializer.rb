# frozen_string_literal: true

require 'fast_jsonapi'

module Mobile
  module V0
    class PaymentHistorySerializer
      include FastJsonapi::ObjectSerializer
    end
  end
end