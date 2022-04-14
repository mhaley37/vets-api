# frozen_string_literal: true

require 'common/models/resource'

module Mobile
  module V0
    class Prescription < Common::Resource
      attribute :id, Types::String
      attribute :prescription_name, Types::String
      attribute :prescription_number, Types::String.optional
      attribute :refill_status, Types::String
      attribute :refill_submit_date, Types::DateTime
      attribute :refill_date, Types::DateTime
      attribute :refill_remaining, Types::Integer
      attribute :facility_name, Types::String
      attribute :ordered_date, Types::DateTime
      attribute :quantity, Types::Integer
      attribute :expiration_date, Types::DateTime
      attribute :dispensed_date, Types::DateTime
      attribute :station_number, Types::String
      attribute :is_refillable, Types::Bool
      attribute :is_trackable, Types::Bool
    end
  end
end