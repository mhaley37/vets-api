# frozen_string_literal: true

module VBADocuments
  module Registrations
    include Webhooks::Utilities

    WEBHOOK_STATUS_CHANGE_EVENT = 'gov.va.benefits-intake.status_change'
    WEBHOOK_API_NAME = 'GOV.VA.BENEFITS-INTAKE'
    WEBHOOK_DEFAULT_RUN_MINS = 5

    register_events(WEBHOOK_STATUS_CHANGE_EVENT,
                    api_name: WEBHOOK_API_NAME,
                    max_retries: Settings.vba_documents.webhooks.registration_max_retries || 3) do |last|
      registration_next_run_mins = Settings.vba_documents.webhooks.registration_next_run_in_minutes
      next_run = last ? (registration_next_run_mins || WEBHOOK_DEFAULT_RUN_MINS) : 0
      next_run.minutes.from_now
    rescue
      WEBHOOK_DEFAULT_RUN_MINS.minutes.from_now
    end

    # todo place documentation outlining structure of failure data.  Something like:
    #  {"404"=>6, "420"=>4, "503"=>7, "total"=>27, "Faraday::Error"=>6, "Faraday::ClientError"=>4}
    register_failure_handler(api_name: WEBHOOK_API_NAME) do |failure_data|
      Rails.logger.info("Webhooks: failure handler got #{failure_data}")
      # {"404"=>6, "420"=>4, "503"=>7, "total"=>27, "Faraday::Error"=>6, "Faraday::ClientError"=>4}
      next_run_mins =
        case failure_data['total']
        when 1..3
          0
        when 4..10
          5
        when 11..20
          20
        when 21..50
          40
        else
          80
        end

      next_run_mins.minutes.from_now.to_i
    end
  end
end
