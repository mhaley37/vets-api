# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)
        payments = adapt_payments(response.dig(:payments, :payment))

        render json: Mobile::V0::PaymentHistorySerializer.new(payments)
      end

      #---------
      # {:beneficiary_participant_id=>"600061742",
      #  :file_number=>"796043735",
      #  :payee_type=>"Veteran",
      #  :payment_amount=>"3444.7",
      #  :payment_date=>Tue, 31 Dec 2019 00:00:00 -0600,
      #  :payment_status=>"Scheduled",
      #  :payment_type=>"Compensation & Pension - Recurring",
      #  :payment_type_code=>"1",
      #  :program_type=>"Compensation",
      #  :recipient_name=>"WESLEYFORD",
      #  :recipient_participant_id=>"600061742",
      #  :scheduled_date=>Thu, 12 Dec 2019 00:00:00 -0600,
      #  :veteran_name=>"WESLEYFORD",
      #  :veteran_participant_id=>"600061742",
      #  :address_eft=>{:account_number=>"123456", :account_type=>"Checking", :bank_name=>"BANK OF AMERICA, N.A.", :routing_number=>"111000025"},
      #  :check_address=>
      #    {:address_line1=>nil, :address_line2=>nil, :address_line3=>nil, :address_line4=>nil, :address_line5=>nil, :address_line6=>nil, :address_line7=>nil, :zip_code=>nil},
      #  :payment_record_identifier=>{:payment_id=>"11213114"},
      #  :return_payment=>{:check_trace_number=>nil, :return_reason=>nil}}
      #---------

      private

      def adapt_payments(payments)
        payments[0..2].map do |payment|
          Mobile::V0::PaymentHistory.new(
            id: payment.dig(:payment_record_identifier, :payment_id),
            payment_amount: payment[:payment_amount],
            payment_date: payment[:payment_date],
            payment_method: 'Check',
            payment_bank: payment.dig(:address_eft, :bank_name),
            payment_account: payment.dig(:address_eft, :account_number)
          )
        end
      end

      # def adapt_payments(payments)
      #   payments[0..2].map do |payment|
      #     Mobile::V0::PaymentHistory.new(
      #       id: payment.dig(:payment_record_identifier, :payment_id),
      #       payment_amount: ActiveSupport::NumberHelper.number_to_currency(payment[:payment_amount]),
      #       payment_date: payment[:payment_date],
      #       payment_method: Adapters::PaymentSharedAdapter.new.get_payment_method(payment),
      #       payment_bank: payment.dig(:address_eft, :bank_name),
      #       payment_account: Adapters::PaymentSharedAdapter.new.mask_account_number(payment[:address_eft])
      #       )
      #   end
      # end

      #will soon remove after refactor
      # def process_all_payments(all_payments)
      #   all_payments = [all_payments] if all_payments.instance_of?(Hash)
      #
      #   all_payments.each do |payment|
      #     process_payment(payment)
      #   end
      # end
      #
      # def process_payment(payment)
      #   @formatted_payments <<
      #     Adapters::PaymentSharedAdapter.new.process_payment(payment)
      # end
    end
  end
end