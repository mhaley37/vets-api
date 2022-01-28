# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class AppointmentRequests
        def parse(requests)
          facilities = Set.new

          appointments = requests.map do |request|
            build_appointment_model(request)
          end

          [appointments, facilities]
        end

        private

        def build_appointment_model(request)
          Mobile::V0::Appointment.new(
            id: request[:appointment_request_id],
            appointment_type: 'VA', # request[:appointment_type], # check that this is actually the same
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
            start_date_utc: nil,
            status: 'REQUESTED',
            status_detail: nil,
            time_zone: nil, # maybe base off of facility?
            vetext_id: nil,
            reason: request[:reason_for_visit],
            is_covid_vaccine: false,
          )
        end

        # should this be the facility or the cc data?
        def location(request)
          # perhaps facility otherwise?
          if request[:cc_appointment_request]
            source = request[:cc_appointment_request]
          else
            binding.pry
          end
          # captures area code \((\d{3})\) number (after space) \s(\d{3}-\d{4})
          # and extension (until the end of the string) (\S*)\z
          phone_captures = request[:phone_number].match(/\((\d{3})\)\s(\d{3}-\d{4})(\S*)\z/)

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
      end
    end
  end
end
