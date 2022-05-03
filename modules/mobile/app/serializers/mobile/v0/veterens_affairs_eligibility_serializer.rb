# frozen_string_literal: true

require 'fast_jsonapi'

module Mobile
  module V0
    class VeterensAffairsEligibilitySerializer
      include FastJsonapi::ObjectSerializer

      set_id :service_name

      set_type :va_eligibility

      attributes :request, :direct

      def initialize(service_eligibilities, service_types)
        resource = service_types.collect do |service|
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

          ServiceStruct.new(
            service,
            request_facilities,
            direct_facilities
          )
        end

        super(resource)
      end
    end

    ServiceEligibilityStruct = Struct.new(:service)
    ServiceStruct = Struct.new(:service_name, :request, :direct)
  end
end
