# frozen_string_literal: true

require 'fast_jsonapi'

module Mobile
  module V0
    class PaymentHistorySerializer
      include FastJsonapi::ObjectSerializer
      set_type :payment_history

      attributes :payment_amount,
                 :payment_date,
                 :payment_method,
                 :payment_bank,
                 :payment_account
    end
  end
end