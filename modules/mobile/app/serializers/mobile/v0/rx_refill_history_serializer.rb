# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :RxHistory
      attributes :refillStatus,
      :refillSubmitDate,
        :refillDate,
        :refillRemaining,
        :facilityName,
        :isRefillable,
        :isTrackable,
        :prescriptionId,
        :orderedDate,
        :quantity,
        :expirationDate,
        :prescriptionNumber,
        :prescriptionName,
        :dispensedDate,
        :stationNumber

      def initialize(id, rx_history)
        resource = rx_history.attributes.collect do |prescription|
          RxHistoryStruct.new(id, *prescription.values)
        end
        super(resource)
      end
    end

    RxHistoryStruct = Struct.new(:id, :refillStatus,
                                 :refillSubmitDate,
                                 :refillDate,
                                 :refillRemaining,
                                 :facilityName,
                                 :isRefillable,
                                 :isTrackable,
                                 :prescriptionId,
                                 :orderedDate,
                                 :quantity,
                                 :expirationDate,
                                 :prescriptionNumber,
                                 :prescriptionName,
                                 :dispensedDate,
                                 :stationNumber)
  end
end
