module Registries
  class WorldLocationsRegistry < Registry
    include CacheableRegistry

    delegate :[], to: :cached_locations

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
        fetch_locations.index_by { |hash| hash["slug"] }
      end
    end

    def fetch_locations
      fetch_locations_from_worldwide_api.map do |result|
        {
          "title" => result["title"],
          "slug" => result.dig("details", "slug"),
          "content_id" => result["content_id"],
        }
      end
    end

    def fetch_locations_from_worldwide_api
      GdsApi::Worldwide.new(worldwide_api_endpoint).world_locations.with_subsequent_pages.to_a
    end

    def worldwide_api_endpoint
      if !Rails.env.production? || ENV["HEROKU_APP_NAME"].present?
        Plek.new.website_root
      else
        Plek.find("whitehall-frontend")
      end
    end
  end
end
