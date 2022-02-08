# frozen_string_literal: true

module Mobile
  module V0
    module Appointments
      # connects to appointment request service
      class AppointmentRequestsService < VAOS::SessionService
        # fetches the past 90 days of appointment requests
        def get_appointment_requests
          response = nil
          error = nil
          end_date = Time.zone.today
          start_date = end_date - 90.days
          date_params = { startDate: date_format(start_date), endDate: date_format(end_date) }

          with_monitoring do
            response = perform(:get, get_requests_url, date_params, headers)
          rescue => e
            error = e
          end

          { response: response, error: error }
        end

        private

        def get_requests_url
          "/var/VeteranAppointmentRequestService/v4/rest/appointment-service/patient/ICN/#{@user.icn}/appointments"
        end

        def date_format(date)
          date.strftime('%m/%d/%Y')
        end
      end
    end
  end
end
