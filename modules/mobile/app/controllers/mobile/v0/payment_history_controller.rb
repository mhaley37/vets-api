# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)

        #
        render json: Mobile::V0::PaymentHistorySerializer.new(response)
      end

      #
      def initialize
        @formatted_payments = []

        process_all_payments(object[:payments][:payment]) if object.dig(:payments, :payment).present?
        super
      end
    end

    #
    def payments
      @formatted_payments
    end

    private

    def process_all_payments(all_payments)
      all_payments = [all_payments] if all_payments.instance_of?(Hash)

      all_payments.each do |payment|
        process_payment(payment)
      end
    end

    def process_payment(payment)
      @formatted_payments <<
        Adapters::PaymentSharedAdapter.new.process_payment(payment)
    end

    def paginate(payments, validated_params)
      payments = payments.filter do |payment|
        payment.start_date_utc.between? validated_params[:start_date], validated_params[:end_date]
      end
      url = request.base_url + request.path
      Mobile::PaginationHelper.paginate(list: payments, validated_params: validated_params, url: url)
    end
  end
end