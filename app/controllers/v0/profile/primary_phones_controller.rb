# frozen_string_literal: true

module V0
  module Profile
    class PrimaryPhonesController < ApplicationController
      include EVSS::Authorizeable

      before_action :authorize_evss!

      def show
        number = VaFileNumber.find(params[:id])
        response = service.get_primary_phone

        render json: response, serializer: PhoneNumberSerializer
      end

      def create
        phone = EVSS::PCIU::PhoneNumber.new primary_phone_params

        if phone.valid?
          response = service.post_primary_phone phone

          render json: response, serializer: PhoneNumberSerializer
        else
          raise Common::Exceptions::ValidationErrors, phone
        end
      end

      private

      def service
        EVSS::PCIU::Service.new @current_user
      end

      def primary_phone_params
        params.permit(:country_code, :number, :extension, :effective_date)
      end
    end
  end
end
