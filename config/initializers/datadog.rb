# frozen_string_literal: true

if !Rails.env.test?
require 'ddtrace'

  Datadog.configure do |c|
    c.use :rails, { log_injection: true }
    c.use :sidekiq, { tag_args: true }
  end
end
