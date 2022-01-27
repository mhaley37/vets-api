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

        def build_appointment_model(request)
          appointment = Mobile::V0::Appointment.new(adapted_hash)
        end
      end
    end
  end
end
