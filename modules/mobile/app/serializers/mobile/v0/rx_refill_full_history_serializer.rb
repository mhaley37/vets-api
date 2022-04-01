# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillFullHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :prescriptionsHistory
      attributes :prescriptionsHistory

      def initialize(id, prescriptions)
        resource = PrescriptionsHistoryStruct.new(id, prescriptions)
        super(resource)
      end
    end

    PrescriptionsHistoryStruct = Struct.new(:id, :prescriptionsHistory)
  end
end
