# frozen_string_literal: true

require 'common/models/resource'

module Mobile
  module V0
    class RxHistory < Common::Resource
      attribute :rx_history, Types::Array.of(Prescription)
    end
  end
end