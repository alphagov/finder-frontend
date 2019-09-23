module Registries
  class WorldLocationsRegistry < Registry
    include CacheableRegistry

    def [](slug)
      cached_locations[slug]
    end

    def values
      cached_locations
    end

    def cache_key
      "#{NAMESPACE}/world_locations"
    end

  private

    def cacheable_data
      locations
    end

    def report_error
      GovukStatsd.increment("#{NAMESPACE}.world_location_api_errors")
    end

    def cached_locations
      @cached_locations ||= fetch_from_cache
    end

    def locations
      GovukStatsd.time("registries.world_locations.request_time") do
        fetch_locations.each_with_object({}) { |hash, result_hash|
          result_hash[hash["slug"]] = hash
        }
      end
    end

    def fetch_locations
      fetch_locations_from_worldwide_api.map { |result|
        {
          "title" => result["title"],
          "slug" => result.dig("details", "slug"),
          "content_id" => result["content_id"],
        }
      }
    end

    def fetch_locations_from_worldwide_api
      Services.worldwide_api.world_locations.with_subsequent_pages.to_a
    end
  end
end
