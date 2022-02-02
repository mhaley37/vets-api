# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class AppointmentRequests
        def parse(requests)
          # a bit unclear how to handle this
          # facilities = Set.new

          requests.map do |request|
            status = status(request)
            next unless status

            start_date = start_date(request)
            proposed_times = proposed_times(request)
            adapter_klass = type_adapter(request)
            adapter_klass.build_appointment_model(start_date, proposed_times, status)
          end.compact
        end

        private

        def type_adapter(request)
          if request.key?(:cc_appointment_request)
            CC.new(request)
          else
            VA.new(request)
          end
        end

        def proposed_times(request)
          {
            option_date1: request[:option_date1],
            option_time1: request[:option_time1],
            option_date2: request[:option_date2],
            option_time2: request[:option_time2],
            option_date3: request[:option_date3],
            option_time3: request[:option_time3]
          }
        end

        def start_date(request)
          date = request[:option_date1]
          month, day, year = date.split('/').map(&:to_i)
          hour = request[:option_time1] == 'AM' ? 9 : 13

          DateTime.new(year, month, day, hour, 0)
        end

        def status(request)
          received_status = request[:status].upcase
          return received_status if received_status.in?(%w[CANCELLED SUBMITTED])

          nil
        end

        # needs:
        # provider name
        # facility address (handled separately i believe)
        # facility phone, also pulled from separate facility request
        # user's contact info: email, phone, preferred call time
        class VA
          attr_accessor :request

          def initialize(request)
            @request = request
          end

          def build_appointment_model(start_date, proposed_times, status)
            Mobile::V0::Appointment.new(
              id: request[:appointment_request_id],
              appointment_type: 'VA_REQUEST',
              cancel_id: nil,
              comment: nil,
              facility_id: request.dig(:facility, :facility_code),
              sta6aid: nil,
              healthcare_provider: nil,
              healthcare_service: nil,
              location: location,
              minutes_duration: nil,
              phone_only: nil,
              start_date_local: nil,
              start_date_utc: start_date,
              status: status,
              status_detail: nil,
              time_zone: nil, # maybe base off of facility?
              vetext_id: nil,
              reason: request[:reason_for_visit],
              is_covid_vaccine: false,
              proposed_times: proposed_times,
              type_of_care: request[:appointment_type],
              visit_type: request[:visit_type]
            )
          end

          private

          def location
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
        end

        # needs:
        # user's contact info
        class CC
          attr_accessor :request

          def initialize(request)
            @request = request
          end

          def build_appointment_model(start_date, proposed_times, status)
            Mobile::V0::Appointment.new(
              id: request[:appointment_request_id],
              appointment_type: 'COMMUNITY_CARE_REQUEST',
              cancel_id: nil,
              comment: nil,
              facility_id: request.dig(:facility, :facility_code),
              sta6aid: nil,
              healthcare_provider: provider_name,
              healthcare_service: practice_name,
              location: location,
              minutes_duration: nil,
              phone_only: nil,
              start_date_local: nil,
              start_date_utc: start_date,
              status: status,
              status_detail: nil,
              time_zone: nil, # maybe base off of facility?
              vetext_id: nil,
              reason: request[:reason_for_visit],
              is_covid_vaccine: false,
              proposed_times: proposed_times,
              type_of_care: request[:appointment_type],
              visit_type: request[:visit_type]
            )
          end

          private

          def provider_name
            provider_section = request.dig(:cc_appointment_request, :preferred_providers, 0)
            if provider_section.nil? || (provider_section[:first_name].nil? && provider_section[:last_name].nil?)
              return nil
            end

            "#{provider_section[:first_name]} #{provider_section[:last_name]}".strip
          end

          def practice_name
            request.dig(:cc_appointment_request, :preferred_providers, 0, :practice_name)
          end

          # should this be the facility or the cc data?
          def location
            source = request[:cc_appointment_request]
            {
              id: nil,
              name: practice_name,
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

          def phone_captures
            # captures area code \((\d{3})\) number (after space) \s(\d{3}-\d{4})
            # and extension (until the end of the string) (\S*)\z
            @phone_captures ||= request[:phone_number].match(/\((\d{3})\)\s(\d{3}-\d{4})(\S*)\z/)
          end
        end
      end
    end
  end
end
