module Registries
  class TopicalEventsRegistry < Registry
    include CacheableRegistry

    delegate :[], to: :topical_events

    def values
      topical_events
    end

    def cache_key
      "registries/topical_events"
    end

  private

    def cacheable_data
      topical_events_as_hash
    end

    def topical_events
      @topical_events ||= fetch_from_cache
    end

    def report_error
      GovukStatsd.increment("registries.topical_events_api_errors")
    end

    def topical_events_as_hash
      GovukStatsd.time("registries.topical_events.request_time") do
        fetch_topical_events_from_rummager
          .reject { |topical_event| topical_event["slug"].empty? || topical_event["title"].empty? }
          .each_with_object({}) do |topical_event, topical_events|
            topical_events[topical_event["slug"]] = { "title" => topical_event["title"], "slug" => topical_event["slug"] }
          end
      end
    end

    def fetch_topical_events_from_rummager
      params = {
        filter_format: "topical_event",
        fields: %w[title slug],
        count: 1500,
        order: "title",
      }
      Services.rummager.search(params)["results"]
    end
  end
end
