# frozen_string_literal: true

require 'common/models/resource'

module Mobile
  module V0
    class PaymentHistory < Common::Resource
      attribute :payment_amount, Types::String
      attribute :payment_date, Types::String.optional
      attribute :payment_method, Types::String.optional
      attribute :payment_bank, Types::String.optional
      attribute :payment_account, Types::String
    end
  end
end