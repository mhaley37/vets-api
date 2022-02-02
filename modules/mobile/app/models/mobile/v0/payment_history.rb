# frozen_string_literal: true

require 'common/models/resource'

module Mobile
  module V0
    class PaymentHistory < Common::Resource
      attribute :id, Types::String
      attribute :payment_amount, Types::Float
      attribute :payment_date, Types::DateTime
      attribute :payment_method, Types::String
      attribute :payment_bank, Types::String
      attribute :payment_account, Types::String
    end
  end
end