# frozen_string_literal: true

module Sidekiq::MeasureRunTime
  def measure_run_time
    starting = Time.current
    yield
    StatsD.measure "shared.sidekiq.#{self.class}.runtime", Time.current - starting
  end
end
