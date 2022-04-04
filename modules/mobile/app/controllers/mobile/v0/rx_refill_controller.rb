# frozen_string_literal: true

require 'rx/client'

module Mobile
  module V0
    class RxRefillController < ApplicationController
      before_action { authorize :mhv_prescriptions, :access? }

      def get_full_rx_history
        response = client.get_history_rxs
        binding.pry
        rx_history = rx_history_adapter.parse(response)
        render json: Mobile::V0::RxRefillHistorySerializer.new(@current_user.id, rx_history.rx_history.attributes)
      end

      def get_tracking_history
        response = client.get_tracking_history_rx(params[:id])
        rx_history = rx_history_adapter.parse(response)
        render json: Mobile::V0::RxRefillHistorySerializer.new(@current_user.id, rx_history.rx_history.attributes)
      end

      def post_refill
        client.post_refill_rx(params[:id])

        head :no_content
      end

      def get_preferences
        render json: Mobile::V0::RxRefillPreferencesSerializer.new(client.get_preferences)
      end

      def post_preferences
        client.post_preferences(params.permit(:rx_flag, :email_address))

        head :no_content
      end

      def get_prescription
        test =  client.get_rx(params[:id])
        binding.pry
        prescription = prescription_adapter.parse(test)
        render json: Mobile::V0::RxRefillPrescriptionSerializer.new(prescription)
      end

      private

      def prescription_adapter
        Mobile::V0::Adapters::Prescription.new
      end

      def rx_history_adapter
        Mobile::V0::Adapters::RxHistory.new
      end

      def client
        @client ||= Rx::Client.new(session: { user_id: @current_user.mhv_correlation_id })
      end
    end
  end
end
