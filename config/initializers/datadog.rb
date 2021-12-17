# frozen_string_literal: true

require 'ddtrace'

# @see https://docs.datadoghq.com/tracing/setup_overview/setup/ruby
Datadog.configure do |c|
  c.tracer.enabled = !Rails.env.test?
  c.service = 'vets-api'
  c.env = Settings.vsp_environment
  c.use :rails, { log_injection: true }
  c.use :sidekiq, { tag_args: true }
end
