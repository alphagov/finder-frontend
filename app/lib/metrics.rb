require "benchmark"

module Metrics
  CLIENT = PrometheusExporter::Client.default
  COUNTERS = {
    searches: CLIENT.register(
      :counter,
      "finder_frontend_searches_total",
      "Total number of requests performed to a backend search API",
    ),
  }.freeze
  HISTOGRAMS = {
    search_request_duration: CLIENT.register(
      :histogram,
      "finder_frontend_search_request_duration_seconds",
      "Time taken to perform a request to a backend search API",
    ),
  }.freeze

  def self.increment_counter(counter, labels = {})
    Rails.logger.warn("Unknown counter: #{counter}") and return unless COUNTERS.key?(counter)

    COUNTERS[counter].observe(1, labels)
  rescue StandardError
    # Metrics are best effort only, don't raise if they fail
  end

  def self.observe_duration(histogram, labels = {}, &block)
    unless HISTOGRAMS.key?(histogram)
      Rails.logger.warn("Unknown histogram: #{histogram}")
      return block.call
    end

    result = nil
    duration = Benchmark.realtime do
      result = block.call
    end

    begin
      HISTOGRAMS[histogram].observe(duration, labels)
    rescue StandardError
      # Metrics are best effort only, don't raise if they fail
    end

    result
  end
end
