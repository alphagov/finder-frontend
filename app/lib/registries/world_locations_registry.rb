module Registries
  class WorldLocationsRegistry
    CACHE_KEY = "#{NAMESPACE}/world_locations".freeze

    def [](slug)
      begin
        cached_locations[slug]
      rescue TypeError
        # The cached data was at one point an array, this can be removed later.
        retry if cached_locations.is_a?(Array) && uncache_locations
      end
    end

    def values
      cached_locations
    end

  private

    def cached_locations
      @cached_locations ||= Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        locations
      end
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      GovukStatsd.increment("#{NAMESPACE}.world_location_api_errors")
      {}
    end

    def uncache_locations
      Rails.cache.delete(CACHE_KEY)
    end

    def locations
      GovukStatsd.time("registries.world_locations.request_time") do
        fetch_locations.each_with_object({}) { |hash, result_hash|
          result_hash[hash['slug']] = hash
        }
      end
    end

    def fetch_locations
      fetch_locations_from_worldwide_api.map { |result|
        {
          'title' => result['title'],
          'slug' => result.dig('details', 'slug')
        }
      }
    end

    def fetch_locations_from_worldwide_api
      Services.worldwide_api.world_locations.with_subsequent_pages.to_a
    end
  end
end
