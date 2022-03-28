# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillFullHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescriptions
      attributes :prescriptions

      def initialize(id, prescriptions)
        resource = PrescriptionsStruct.new(id,prescriptions)
        super(resource)
      end
    end

    PrescriptionsStruct = Struct.new(:id,:prescriptions)
  end
end

