# frozen_string_literal: true

require 'rx/client'

module Mobile
  module V0
    class RxRefillController < ApplicationController
      before_action { authorize :mhv_prescriptions, :access? }

      def get_full_rx_history
        render json: Mobile::V0::RxRefillFullHistorySerializer.new(@current_user.id, client.get_history_rxs)
      end

      def get_preferences
        render json: client.get_preferences
      end

      def post_preferences
        render json: client.post_preferences(params)
      end

      def get_prescription
        render json: client.get_rx(params[:id])
      end

      def post_refill
        render json: client.post_refill_rx(params[:id])
      end

      def get_single_rx_history
        render json: Mobile::V0::RxRefillSingleHistorySerializer.new(
          @current_user.id, client.get_tracking_history_rx(params[:id])
        )
      end

      private

      def client
        @client ||= Rx::Client.new(session: { user_id: @current_user.mhv_correlation_id })
      end
    end
  end
end
