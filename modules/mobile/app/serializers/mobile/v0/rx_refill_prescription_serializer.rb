# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillPrescriptionSerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescription
      attributes
      %i[prescriptionId
         prescriptionNumber
         prescriptionName
         refillStatus
         refillSubmitDate
         refillDate
         refillRemaining
         facilityName
         orderedDate
         quantity
         expirationDate
         dispensedDate
         stationNumber
         isRefillable
         isTrackable
         links]
    end
  end
end
