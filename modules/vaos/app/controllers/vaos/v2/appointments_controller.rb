# frozen_string_literal: true

require 'common/exceptions'
require 'vaos_appointments/appointments_helper'

module VAOS
  module V2
    class AppointmentsController < VAOS::V0::BaseController
      def index
        appointments

        _include&.include?('clinics') && merge_clinics(appointments[:data])
        _include&.include?('facilities') && merge_facilities(appointments[:data])

        serializer = VAOS::V2::VAOSSerializer.new
        serialized = serializer.serialize(appointments[:data], 'appointments')
        render json: { data: serialized, meta: appointments[:meta] }
      end

      def show
        appointment = appointments_helper.get_appointment_location_info(get_appointment)
        serializer = VAOS::V2::VAOSSerializer.new
        serialized = serializer.serialize(appointment, 'appointments')
        render json: { data: serialized }
      end

      def create
        new_appointment = appointments_helper.create_new_appointment(params)
        serializer = VAOS::V2::VAOSSerializer.new
        serialized = serializer.serialize(new_appointment, 'appointments')
        render json: { data: serialized }, status: :created
      end

      def update
        updated_appointment = appointments_helper.get_appointment_location_info(update_appointment)
        serializer = VAOS::V2::VAOSSerializer.new
        serialized = serializer.serialize(updated_appointment, 'appointments')
        render json: { data: serialized }
      end

      private

      def appointments_helper
        @appointments_helper ||= VAOSAppointments::AppointmentsHelper.new(current_user)
      end

      def appointments_service
        VAOS::V2::AppointmentsService.new(current_user)
      end

      def appointments
        @appointments ||=
          appointments_service.get_appointments(start_date, end_date, statuses, pagination_params)
      end

      def get_appointment
        @appointment ||=
          appointments_service.get_appointment(appointment_id)
      end

      def new_appointment
        @new_appointment ||=
          appointments_service.post_appointment(create_params)
      end

      def update_appointment
        @updated_appointment ||=
          appointments_service.update_appointment(update_appt_id, status_update)
      end

      def merge_clinics(appointments)
        cached_clinics = {}
        appointments.each do |appt|
          unless appt[:clinic].nil?
            unless cached_clinics[:clinic]
              clinic = appointments_helper.get_clinic(appt[:location_id], appt[:clinic])
              cached_clinics[appt[:clinic]] = clinic
            end
            if cached_clinics[appt[:clinic]]&.[](:service_name)
              appt[:service_name] = cached_clinics[appt[:clinic]][:service_name]
            end
            if cached_clinics[appt[:clinic]]&.[](:physical_location)
              appt[:physical_location] = cached_clinics[appt[:clinic]][:physical_location]
            end
          end
        end
      end

      def merge_facilities(appointments)
        cached_facilities = {}
        appointments.each do |appt|
          unless appt[:location_id].nil?
            unless cached_facilities[:location_id]
              facility = appointments_helper.get_facility(appt[:location_id])
              cached_facilities[appt[:location_id]] = facility
            end

            appt[:location] = cached_facilities[appt[:location_id]] if cached_facilities[appt[:location_id]]
          end
        end
      end

      def update_appt_id
        params.require(:id)
      end

      def status_update
        params.require(:status)
      end

      def appointment_params
        params.require(:start)
        params.require(:end)
        params.permit(:start, :end, :_include)
      end

      def start_date
        DateTime.parse(appointment_params[:start]).in_time_zone
      rescue ArgumentError
        raise Common::Exceptions::InvalidFieldValue.new('start', params[:start])
      end

      def end_date
        DateTime.parse(appointment_params[:end]).in_time_zone
      rescue ArgumentError
        raise Common::Exceptions::InvalidFieldValue.new('end', params[:end])
      end

      def _include
        appointment_params[:_include]&.split(',')
      end

      def statuses
        s = params[:statuses]
        s.is_a?(Array) ? s.to_csv(row_sep: nil) : s
      end

      def appointment_id
        params[:appointment_id]
      rescue ArgumentError
        raise Common::Exceptions::InvalidFieldValue.new('appointment_id', params[:appointment_id])
      end
    end
  end
end
