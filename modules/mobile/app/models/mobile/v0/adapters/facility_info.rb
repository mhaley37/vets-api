# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class FacilityInfo
        def parse(facility, user, params)
          user_location = params[:sort] == 'current' ? current_coords(params) : home_coords(user)

          if Flipper.enabled?(:mobile_appointment_use_VAOS_MFS)
            Mobile::V0::FacilityInfo.new(
              id: facility.id,
              name: facility[:name],
              city: facility[:physical_address][:city],
              state: facility[:physical_address][:state],
              cerner: user.cerner_facility_ids.include?(facility.id),
              miles: haversine_distance(user_location, [facility.lat, facility.long]).to_s,
              clinics: [] # blank for now, will be used by direct scheduling
            )
          else
            Mobile::V0::FacilityInfo.new(
              id: facility.id[4, 3],
              name: facility[:name],
              city: facility[:address].dig('physical', 'city'),
              state: facility[:address].dig('physical', 'state'),
              cerner: user.cerner_facility_ids.include?(facility.id[4, 3]),
              miles: haversine_distance(user_location, [facility.lat, facility.long]).to_s,
              clinics: [] # blank for now, will be used by direct scheduling
            )
          end
        end

        private

        def current_coords(params)
          params.require(:lat)
          params.require(:long)
          [params[:lat].to_f, params[:long].to_f]
        end

        def home_coords(user)
          Mobile::FacilitiesHelper.user_address_coordinates(user)
        end

        ##
        # Haversine Distance Calculation
        #
        # Accepts two coordinates in the form
        # of a tuple. I.e.
        #   geo_a  Array(Num, Num)
        #   geo_b  Array(Num, Num)
        #   miles  Boolean
        #
        # Returns the distance between these two
        # points in either miles or kilometers
        def haversine_distance(geo_a, geo_b, miles: true)
          # Get latitude and longitude
          lat1, lon1 = geo_a
          lat2, lon2 = geo_b

          # Calculate radial arcs for latitude and longitude
          d_lat = (lat2 - lat1) * Math::PI / 180
          d_lon = (lon2 - lon1) * Math::PI / 180

          a = Math.sin(d_lat / 2) *
              Math.sin(d_lat / 2) +
              Math.cos(lat1 * Math::PI / 180) *
              Math.cos(lat2 * Math::PI / 180) *
              Math.sin(d_lon / 2) * Math.sin(d_lon / 2)

          c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

          6371 * c * (miles ? 1 / 1.6 : 1)
        end
      end
    end
  end
end
