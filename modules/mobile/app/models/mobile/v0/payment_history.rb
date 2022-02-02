# frozen_string_literal: true

require 'common/models/resource'

module Mobile
  module V0
    class PaymentHistory < Common::Resource
      attribute :id, Types::String
      attribute :amount, Types::Float
      attribute :date, Types::DateTime
      attribute :method, Types::String
      attribute :bank, Types::String.optional
      attribute :account, Types::String.optional
    end
  end
end