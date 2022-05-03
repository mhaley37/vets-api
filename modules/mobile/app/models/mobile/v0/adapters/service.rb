# frozen_string_literal: true

require 'common/models/base'
require 'date'

module Mobile
  module V0
    module Adapters
      class Service
        # 411 = Podiatry
        SERVICE_TYPE_IDS = %w[amputation primaryCare foodAndNutrition 411 optometry audiology].freeze

        def parse(service_eligibilities)
          SERVICE_TYPE_IDS.collect do |service|
            request_facilities = []
            direct_facilities = []

            service_eligibilities.each do |facility|
              facility_id = facility.facility_id
              service_index = facility.services.index { |h| h[:id] == service }
              facility_service = facility.services[service_index]
              next if service_index.nil?

              request_facilities << facility_id if facility_service.dig(:request, :enabled)
              direct_facilities << facility_id if facility_service.dig(:direct, :enabled)
            end

            request_facilities.compact!
            direct_facilities.compact!

            Mobile::V0::Service.new(
              name: service,
              request_eligible_facilities: request_facilities,
              direct_eligible_facilities: direct_facilities
            )
          end
        end
      end
    end
  end
end
