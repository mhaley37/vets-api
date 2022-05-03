# frozen_string_literal: true

module Mobile
  module V0
    class VeterensAffairsEligibilityController < ApplicationController
      def show
        response = mobile_facility_service.get_scheduling_configurations(csv_facility_ids)
        services = service_adapter.parse(response[:data])

        render json: Mobile::V0::VeterensAffairsEligibilitySerializer.new(@current_user.id, services)
      end

      private

      def service_adapter
        Mobile::V0::Adapters::Service.new
      end

      def mobile_facility_service
        VAOS::V2::MobileFacilityService.new(@current_user)
      end

      def csv_facility_ids
        ids = params.require(:facilityIds)
        ids.is_a?(Array) ? ids.to_csv(row_sep: nil) : ids
      end
    end
  end
end
