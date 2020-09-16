# frozen_string_literal: true

module VAOS
  module V0
    class DirectBookingEligibilityCriteriaController < VAOS::V0::BaseController
      def index
        response = systems_service.get_direct_booking_elig_crit(
          site_codes: url_params[:site_codes]
        )
        render json: VAOS::V0::DirectBookingEligibilityCriteriaSerializer.new(response)
      end

      private

      def url_params
        params[:site_codes].is_a?(Array) ? params.permit(site_codes: []) : params.permit(:site_codes)
        params
      end

      def systems_service
        VAOS::SystemsService.new(current_user)
      end
    end
  end
end
