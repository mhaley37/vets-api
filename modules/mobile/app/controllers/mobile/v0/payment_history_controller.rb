# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        render json: Mobile::V0::PaymentHistorySerializer
      end
    end
  end
end