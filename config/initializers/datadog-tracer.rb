# frozen_string_literal: true
ENV['DD_AGENT_HOST'] ||= 'datadog-agent'
ENV['DD_TRACE_AGENT_PORT'] ||= '8126'

Datadog.configure do |c|
  c.service = 'vets-api'
end
