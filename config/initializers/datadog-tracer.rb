# frozen_string_literal: true

Datadog.configure do |c|
  c.service = 'vets-api'
  c.tracer hostname: '172.17.0.3',
           port: 8126
end
