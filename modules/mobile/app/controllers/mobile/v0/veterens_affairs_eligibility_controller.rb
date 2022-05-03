# frozen_string_literal: true

module Mobile
  module V0
    class VeterensAffairsEligibilityController < ApplicationController
      # 411 = Podiatry
      SERVICE_TYPE_IDS = %w[amputation primaryCare foodAndNutrition 411 optometry audiology].freeze

      def show
        response = mobile_facility_service.get_scheduling_configurations(csv_facility_ids)
        render json: Mobile::V0::VeterensAffairsEligibilitySerializer.new(
          response[:data], SERVICE_TYPE_IDS
        )
      end

      private

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
