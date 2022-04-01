# frozen_string_literal: true

require 'common/models/base'
require 'date'

module Mobile
  module V0
    module Adapters
      class RxHistory
        def parse(rx_history)
          Mobile::V0::RxHistory.new(
            rx_history: rx_history
          )
        end
      end
    end
  end
end
