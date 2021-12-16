# frozen_string_literal: true

Datadog.configure do |c|
  c.service = 'vets-api'
  c.tracer hostname: 'datadog-agent',
           port: 8126
end
