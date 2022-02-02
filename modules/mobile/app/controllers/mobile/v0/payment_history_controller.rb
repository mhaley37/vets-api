# frozen_string_literal: true

require_dependency 'mobile/application_controller'
require 'adapters/payment_history_adapter'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        start_date = params[:startDate] || (DateTime.now.utc.beginning_of_day - 1.year).iso8601
        end_date = params[:endDate] || (DateTime.now.utc.beginning_of_day).iso8601

        validated_params = Mobile::V0::Contracts::GetPaginatedList.new.call(
          start_date: start_date,
          end_date: end_date,
          page_number: params.dig(:page, :number),
          page_size: params.dig(:page, :size),
          use_cache: false,
          reverse_sort: false
        )

        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)
        payments = adapt_payments(response.dig(:payments, :payment))
        # paginated = paginate(payments, validated_params)

        # render json: Mobile::V0::PaymentHistorySerializer.new(paginated)
        list, meta = paginate(payments, validated_params)
        binding.pry
        render json: Mobile::V0::PaymentHistorySerializer.new(list, meta)
      end

      private

      def adapt_payments(payments)
        payments.map do |payment|
          Mobile::V0::PaymentHistory.new(
            id: payment.dig(:payment_record_identifier, :payment_id),
            amount: ActiveSupport::NumberHelper.number_to_currency(payment[:payment_amount]),
            date: payment[:payment_date],
            method: ::Adapters::PaymentSharedAdapter.new.get_payment_method(payment),
            bank: payment.dig(:address_eft, :bank_name),
            account: ::Adapters::PaymentSharedAdapter.new.mask_account_number(payment[:address_eft])
            ) unless payment.dig(:return_payment, :check_trace_number).present?
        end
      end

      def paginate(payments, validated_params)
        # payments = payments.filter do |payment|
        #   payment.date.between? validated_params[:start_date], validated_params[:end_date]
        # end
        url = request.base_url + request.path
        Mobile::PaginationHelper.paginate(list: payments, validated_params: validated_params, url: url)
      end
    end
  end
end