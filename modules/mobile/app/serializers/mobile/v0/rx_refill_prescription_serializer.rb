# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillPrescriptionSerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescription
      attributes :id,
                 :prescription_name,
                 :refill_status,
                 :refill_submit_date,
                 :refill_date,
                 :refill_remaining,
                 :facility_name,
                 :ordered_date,
                 :quantity,
                 :expiration_date,
                 :dispensed_date,
                 :station_number,
                 :is_refillable,
                 :is_trackable
    end
  end
end
