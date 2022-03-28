# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillSingleHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescription
      attributes :prescription

      def initialize(id, prescription)
        resource = PrescriptionStruct.new(id, prescription)
        super(resource)
      end
    end

    PrescriptionStruct = Struct.new(:id, :prescription)
  end
end

