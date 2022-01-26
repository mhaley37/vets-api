# frozen_string_literal: true

module Mobile
  module V0
    module Appointments
      # Connect's to VAMF's VA appointment and Community Care appointment services.
      #
      # @example create a new instance and call the get_appointment's endpoint
      #   service = Mobile::V0::Appointments::Service.new(user)
      #   response = service.get_appointments(start_date, end_date)
      #
      class Service < VAOS::SessionService
        # Given a date range returns a list of VA appointments, including video appointments, and
        # a list of Community Care appointments. The calls are made in parallel using the Typhoeus
        # HTTP adapter.
        #
        # @start_date DateTime the start of the date range
        # @end_date DateTime the end of the date range
        #
        # @return Hash two lists of appointments, va and cc (community care)
        #
        def get_appointments(start_date, end_date)
          params = {
            startDate: start_date.utc.iso8601,
            endDate: end_date.utc.iso8601,
            pageSize: 0,
            useCache: false
          }

          responses = { cc: nil, va: nil, requests: nil }
          errors = { cc: nil, va: nil, requests: nil }

          va_response, cc_response, requests_response = Parallel.map([fetch_va_appointments(params), fetch_cc_appointments(params), fetch_appointment_requests(start_date, end_date)], in_threads: 3, &:call)

          responses[:va], errors[:va] = va_response
          responses[:va], errors[:va] = cc_response
          responses[:requests] = requests_response # needs error handling

          [responses, errors]
        end

        private

        def get(url, params)
          response = config.connection.get(url, params, headers)
          [response, nil]
        rescue VAOS::Exceptions::BackendServiceException => e
          vaos_error(e, url)
        rescue => e
          internal_error(e, url)
        end

        def config
          Mobile::V0::Appointments::Configuration.instance
        end

        def va_url
          "/appointments/v1/patients/#{@user.icn}/appointments"
        end

        def cc_url
          '/var/VeteranAppointmentRequestService/v4/rest/direct-scheduling' \
            "/patient/ICN/#{@user.icn}/booked-cc-appointments"
        end

        def fetch_va_appointments(params)
          lambda {
            get(va_url, params)
          }
        end

        def fetch_cc_appointments(params)
          lambda {
            get(cc_url, params)
          }
        end

        # this may need to change to match the error handling of the others
        def fetch_appointment_requests(start_date, end_date)
          lambda {
            VAOS::AppointmentRequestsService.new(@user).get_requests(start_date, end_date)
          }
        end

        def cancel_appointment_url(facility_id)
          "/var/VeteranAppointmentRequestService/v4/rest/direct-scheduling/site/#{facility_id}/patient/ICN/" \
            "#{@user.icn}/cancel-appointment"
        end

        def internal_error(e, url)
          Rails.logger.error(
            'mobile appointments internal exception',
            { url: url, error: e.message, backtrace: e.backtrace }
          )
          error = {
            status: '500',
            source: url == va_url ? 'VA Service' : 'Community Care Service',
            title: 'Internal Server Error',
            detail: e.message
          }

          [nil, error]
        end

        def vaos_error(e, url)
          Rails.logger.error(
            'mobile appointments backend service exception',
            { url: url, error: e.message, backtrace: e.backtrace }
          )
          error = {
            status: '502',
            source: url == va_url ? 'VA Service' : 'Community Care Service',
            title: 'Backend Service Exception',
            detail: e.response_values[:detail]
          }

          [nil, error]
        end

        def log_clinic_details(action, clinic_id, site_code)
          Rails.logger.warn(
            "Clinic does not support VAOS appointment #{action}",
            clinic_id: clinic_id,
            site_code: site_code
          )
        end
      end
    end
  end
end
