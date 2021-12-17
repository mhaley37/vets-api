# frozen_string_literal: true

Datadog.configure do |c|
  c.service = 'vets-api'
  c.env = Settings.vsp_environment
end
