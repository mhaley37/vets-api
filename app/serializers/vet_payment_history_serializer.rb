# frozen_string_literal: true

class VetPaymentHistorySerializer < ActiveModel::Serializer
  type :payment_history

  attribute :payments
  attribute :return_payments

  def id
    nil
  end

  def initialize(object, options = nil)
    @formatted_payments = []
    @returned_payments = []

    process_all_payments(object[:payments][:payment]) if object.dig(:payments, :payment).present?
    super
  end

  def payments
    @formatted_payments
  end

  def return_payments
    @returned_payments
  end

  private

  def process_all_payments(all_payments)
    all_payments = [all_payments] if all_payments.instance_of?(Hash)

    all_payments.each do |payment|
      if payment.dig(:return_payment, :check_trace_number).present?
        process_return_payment(payment)
      else
        process_payment(payment)
      end
    end
  end

  def process_payment(payment)
    @formatted_payments <<
      Adapters::PaymentSharedAdapter.new.process_payment(payment)
  end

  def process_return_payment(payment)
    @returned_payments << {
      returned_check_issue_dt: payment[:payment_date],
      returned_check_cancel_dt: payment[:return_payment][:return_date],
      returned_check_amount: ActiveSupport::NumberHelper.number_to_currency(payment[:payment_amount]),
      returned_check_number: payment[:return_payment][:check_trace_number],
      returned_check_type: payment[:payment_type],
      return_reason: payment[:return_payment][:return_reason]
    }
  end
end
