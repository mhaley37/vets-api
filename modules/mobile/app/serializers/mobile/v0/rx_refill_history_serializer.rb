# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :RxHistory
      attributes :RxHistory

      def initialize(id, rx_history)
        resource = RxHistoryStruct.new(id, rx_history)
        super(resource)
      end
    end

    RxHistoryStruct = Struct.new(:id, :RxHistory)
  end
end
