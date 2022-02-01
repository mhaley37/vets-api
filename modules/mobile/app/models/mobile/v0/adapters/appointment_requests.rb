# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class AppointmentRequests
        def parse(requests)
          # a bit unclear how to handle this
          # facilities = Set.new

          requests.map do |request|
            build_appointment_model(request)
          end
        end

        private

        def build_appointment_model(request)
          Mobile::V0::Appointment.new(
            id: request[:appointment_request_id],
            appointment_type: 'VA', # this is not correct. the appt type returned by the endpoint maps to the label in the list (like "nutrition and food")
            cancel_id: nil,
            comment: nil,
            facility_id: request.dig(:facility, :facility_code),
            sta6aid: nil,
            healthcare_provider: nil,
            healthcare_service: nil,
            location: location(request),
            minutes_duration: nil,
            phone_only: nil,
            start_date_local: nil,
            start_date_utc: start_date(request),
            status: 'REQUESTED',
            status_detail: nil,
            time_zone: nil, # maybe base off of facility?
            vetext_id: nil,
            reason: request[:reason_for_visit],
            is_covid_vaccine: false
          )
        end

        def location(request)
          if request[:cc_appointment_request]
            cc_location(request)
          else
            va_location(request)
          end
        end

        # should this be the facility or the cc data?
        def cc_location(request)
          source = request[:cc_appointment_request]
          phone_captures = phone_captures(request)

          {
            id: nil,
            name: source.dig(:preferred_providers, 0, :practice_name),
            address: {
              street: source.dig(:preferred_providers, 0, :address),
              city: source[:preferred_city],
              state: source[:preferred_state],
              zip_code: source[:preferred_zip_code]
            },
            lat: nil,
            long: nil,
            phone: {
              area_code: phone_captures[1].presence,
              number: phone_captures[2].presence,
              extension: phone_captures[3].presence
            },
            url: nil,
            code: nil
          }
        end

        def va_location(request)
          facility_id = request.dig(:facility, :facility_code)
          facility = Mobile::VA_FACILITIES_BY_ID["dfn-#{facility_id}"]
          {
            id: facility_id,
            name: facility ? facility[:name] : nil,
            address: {
              street: nil,
              city: nil,
              state: nil,
              zip_code: nil
            },
            lat: nil,
            long: nil,
            phone: {
              area_code: nil,
              number: nil,
              extension: nil
            },
            url: nil,
            code: nil
          }
        end

        def start_date(request)
          date = request[:option_date1]
          month, day, year = date.split('/').map(&:to_i)
          hour = request[:option_time1] == 'AM' ? 9 : 13

          DateTime.new(year, month, day, hour, 0)
        end

        def phone_captures(request)
          # captures area code \((\d{3})\) number (after space) \s(\d{3}-\d{4})
          # and extension (until the end of the string) (\S*)\z
          request[:phone_number].match(/\((\d{3})\)\s(\d{3}-\d{4})(\S*)\z/)
        end
      end
    end
  end
end
