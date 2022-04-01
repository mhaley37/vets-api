# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class Prescription
        def parse(prescription)
          Mobile::V0::Prescription.new(
            id: prescription.prescription_id,
            prescription_name: prescription.prescription_name,
            prescription_number: prescription.prescription_number || nil,
            refill_status: prescription.refill_status,
            refill_submit_date: prescription.refill_submit_date,
            refill_date: prescription.refill_date,
            refill_remaining: prescription.refill_remaining,
            facility_name: prescription.facility_name,
            ordered_date: prescription.ordered_date,
            quantity: prescription.quantity,
            expiration_date: prescription.expiration_date,
            dispensed_date: prescription.dispensed_date,
            station_number: prescription.station_number,
            is_refillable: prescription.is_refillable,
            is_trackable: prescription.is_trackable
          )
        end
      end
    end
  end
end
