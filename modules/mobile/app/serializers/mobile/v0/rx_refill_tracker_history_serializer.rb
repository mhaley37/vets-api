# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillTrackerHistorySerializer
      include FastJsonapi::ObjectSerializer

      set_type :RxTrackerHistory
      attributes :RxTrackerHistory

      def initialize(id, rx_tracker_history)
        resource = RxTrackerHistoryStruct.new(id, rx_tracker_history.attributes)
        super(resource)
      end
    end

    RxTrackerHistoryStruct = Struct.new(:id, :RxTrackerHistory)
  end
end
