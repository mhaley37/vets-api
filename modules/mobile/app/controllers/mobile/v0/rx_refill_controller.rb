# frozen_string_literal: true

require 'rx/client'

module Mobile
  module V0
    class RxRefillController < ApplicationController
      before_action { authorize :mhv_prescriptions, :access? }

      def get_rx_history
        render json: Mobile::V0::RxRefillHistorySerializer.new(@current_user.id, client.get_history_rxs)
      end

      def get_tracking_history
        render json: Mobile::V0::RxRefillTrackerHistorySerializer.new(
          @current_user.id,
          client.get_tracking_history_rx(params[:id])
        )
      end

      def post_refill
        client.post_refill_rx(params[:id])

        head :no_content
      end

      def get_preferences
        render json: Mobile::V0::RxRefillPreferencesSerializer.new(client.get_preferences)
      end

      def post_preferences
        render json: Mobile::V0::RxRefillPreferencesSerializer.new(
          client.post_preferences(params.permit(:rx_flag, :email_address))
        )
      end

      def get_prescription
        render json: Mobile::V0::RxRefillPrescriptionSerializer.new(client.get_rx(params[:id]))
      end

      private

      def client
        @client ||= Rx::Client.new(session: { user_id: @current_user.mhv_correlation_id })
      end
    end
  end
end
