# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillPrescriptionSerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescription
      attributes :prescription_name,
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

      def initialize(prescription)
        prescription_hash = prescription.attributes
        prescription_hash[:id] = prescription_hash.delete(:prescription_id)
        resource = PrescriptionStruct.new(*prescription_hash.values_at(*PrescriptionStruct.members))
        super(resource, {})
      end
    end

    PrescriptionStruct = Struct.new(:id,
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
                                    :is_trackable)
  end
end
