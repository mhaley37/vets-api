# frozen_string_literal: true

module Mobile
  module V1
    class ImmunizationSerializer
      include FastJsonapi::ObjectSerializer

      BASE_URL = "#{Settings.hostname}/mobile/v1/health/locations/"

      attributes :cvx_code,
                 :date,
                 :dose_number,
                 :dose_series,
                 :group_name,
                 :manufacturer,
                 :note,
                 :reaction,
                 :short_description

      has_one :location, links: {
        related: lambda { |object|
          object.location_id.nil? ? nil : BASE_URL + object.location_id
        }
      }
    end
  end
end
