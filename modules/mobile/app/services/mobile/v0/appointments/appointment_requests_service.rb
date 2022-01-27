# frozen_string_literal: true

module Mobile
  module V0
    module Appointments
      # connects to appointment request service
      class AppointmentRequestsService < VAOS::SessionService
        def get_requests(start_date, end_date)
          # do we care about this monitoring?
          response = nil
          error = nil
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
          date&.strftime('%m/%d/%Y')
        end
      end
    end
  end
end
