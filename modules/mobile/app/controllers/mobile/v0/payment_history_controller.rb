# frozen_string_literal: true

require_dependency 'mobile/application_controller'
require 'adapters/payment_history_adapter'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)
        payments = adapt_payments(response.dig(:payments, :payment))

        render json: Mobile::V0::PaymentHistorySerializer.new(payments)
      end

      private

      def adapt_payments(payments)
        payments.map do |payment|
          Mobile::V0::PaymentHistory.new(
            id: payment.dig(:payment_record_identifier, :payment_id),
            payment_amount: ActiveSupport::NumberHelper.number_to_currency(payment[:payment_amount]),
            payment_date: payment[:payment_date],
            payment_method: ::Adapters::PaymentSharedAdapter.new.get_payment_method(payment),
            payment_bank: payment.dig(:address_eft, :bank_name),
            payment_account: ::Adapters::PaymentSharedAdapter.new.mask_account_number(payment[:address_eft])
            ) unless payment.dig(:return_payment, :check_trace_number).present?
        end
      end
    end
  end
end