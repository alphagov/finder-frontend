module Registries
  module CacheableRegistry
    def can_refresh_cache?
      true
    end

    def refresh_cache
      Rails.cache.write(cache_key, cacheable_data)
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      report_error
      false
    end

    def fetch_from_cache
      Rails.cache.fetch(cache_key) do
        cacheable_data
      end
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      report_error
      {}
    end

    def cacheable_data
      raise NotImplementedError, "Please supply a cacheable_data method"
    end

    def cache_key
      raise NotImplementedError, "Please supply a cache_key method"
    end

    def report_error
      raise NotImplementedError, "Please supply a report_error method"
    end
  end
end
