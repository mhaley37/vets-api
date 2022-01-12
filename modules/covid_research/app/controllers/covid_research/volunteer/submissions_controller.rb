# frozen_string_literal: true

# Bypass auth requirements
require_dependency 'covid_research/base_controller'

module CovidResearch
  module Volunteer
    class SubmissionsController < BaseController
      STATSD_KEY_PREFIX = "#{STATSD_KEY_PREFIX}.volunteer"
      INTAKE_EMAIL_TEMPLATE_NAME = 'signup_confirmation.html.erb'
      UPDATE_EMAIL_TEMPLATE_NAME = 'update_confirmation.html.erb'

      INTAKE_SCHEMA = 'COVID-VACCINE-TRIAL'
      UPDATE_SCHEMA = 'COVID-VACCINE-TRIAL-UPDATE'

      def create
        form_service = FormService.new(INTAKE_SCHEMA)
        with_monitoring do
          if form_service.valid?(payload)
            ConfirmationMailerJob.perform_async(payload['email'], INTAKE_EMAIL_TEMPLATE_NAME)
            deliver(payload)

            render json: { status: 'accepted' }, status: :accepted
          else
            StatsD.increment("#{STATSD_KEY_PREFIX}.create.fail")

            error = {
              errors: form_service.submission_errors(payload)
            }
            render json: error, status: :unprocessable_entity
          end
        end
      end

      def update
        form_service = FormService.new(UPDATE_SCHEMA)
        with_monitoring do
          if form_service.valid?(payload)
            ConfirmationMailerJob.perform_async(payload['email'], UPDATE_EMAIL_TEMPLATE_NAME)

            deliver(payload)

            render json: { status: 'accepted' }, status: :accepted
          else
            StatsD.increment("#{STATSD_KEY_PREFIX}.update.fail")

            error = {
              errors: form_service.submission_errors(payload)
            }
            render json: error, status: :unprocessable_entity
          end
        end
      end

      private

      def deliver(payload)
        form_service.queue_delivery(payload) if Flipper.enabled?(:covid_volunteer_delivery, @current_user)
      end

      def form_service
        @form_service ||= FormService.new
      end
    end
  end
end
