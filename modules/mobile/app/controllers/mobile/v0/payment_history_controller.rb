# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)

        #use_cache = params[:useCache] || true <- no caching at this time
        start_date = params[:startDate] || one_year_ago.iso8601
        end_date = params[:endDate] || one_year_from_now.iso8601
        reverse_sort = !(params[:sort] =~ /-startDateUtc/).nil?

        validated_params = Mobile::V0::Contracts::GetPaginatedList.new.call(
          start_date: start_date,
          end_date: end_date,
          page_number: params.dig(:page, :number),
          page_size: params.dig(:page, :size),
          #use_cache: use_cache,
          reverse_sort: reverse_sort
        )

        raise Mobile::V0::Exceptions::ValidationErrors, validated_params if validated_params.failure?

        page_history, page_meta_data = paginate(response, validated_params)

        #need to be checked
        render json: Mobile::V0::PaymentHistorySerializer.new(page_history, page_meta_data)
      end

      #X
      def initialize
        @formatted_payments = []

        process_all_payments(object[:payments][:payment]) if object.dig(:payments, :payment).present?
        super
      end
    end

    #X
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