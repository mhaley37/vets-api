# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillSingleHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescriptionHistory
      attributes :prescriptionHistory

      def initialize(id, prescription_history)
        resource = PrescriptionHistoryStruct.new(id, prescription_history)
        super(resource)
      end
    end

    PrescriptionHistoryStruct = Struct.new(:id, :prescriptionHistory)
  end
end
