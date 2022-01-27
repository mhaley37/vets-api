# frozen_string_literal: true

module Adapters
  class PaymentSharedAdapter
    def process_payment(payment)
      {
        pay_check_dt: payment[:payment_date],
        pay_check_amount: ActiveSupport::NumberHelper.number_to_currency(payment[:payment_amount]),
        pay_check_type: payment[:payment_type],
        payment_method: get_payment_method(payment),
        bank_name: payment.dig(:address_eft, :bank_name),
        account_number: mask_account_number(payment[:address_eft])
      }
    end

    def mask_account_number(address_eft, all_but = 4, char = '*')
      return if address_eft.blank?

      account_number = address_eft[:account_number]
      return if account_number.blank?

      account_number&.gsub(/.(?=.{#{all_but}})/, char)
    end

    def get_payment_method(payment)
      return 'Direct Deposit' if payment.dig(:address_eft, :account_number).present?

      return 'Paper Check' if payment.dig(:check_address, :address_line1).present?

      nil
    end
  end
end