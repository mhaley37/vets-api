# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class PaymentHistoryController < ApplicationController
      def index
        person = BGS::PeopleService.new(current_user).find_person_by_participant_id
        response = BGS::PaymentService.new(current_user).payment_history(person)

        render json: Mobile::V0::PaymentHistorySerializer
      end
    end
  end
end