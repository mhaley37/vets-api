# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillFullHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :fullRxHistory
      attributes :fullRxHistory

      def initialize(id, full_rx_history)
        resource = FullRxHistoryStruct.new(id, full_rx_history)
        super(resource)
      end
    end

    FullRxHistoryStruct = Struct.new(:id, :fullRxHistory)
  end
end
