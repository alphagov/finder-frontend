module Registries
  class WorldLocationsRegistry
    CACHE_KEY = "registries/world_locations".freeze

    def all
      @all ||= cached_locations
    end

    def [](slug)
      all.find { |o| o['slug'] == slug }
    end

  private

    def cached_locations
      Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        fetch_locations
      end
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      GovukStatsd.increment("registries.world_location_api_errors")
      []
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
