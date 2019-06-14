module Registries
  module CacheableRegistry
    def can_refresh_cache?
      true
    end

    def refresh_cache
      success = Rails.cache.write(cache_key, cacheable_data)

      raise RefreshOperationFailed unless success
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway, RefreshOperationFailed
      report_error
      raise RefreshOperationFailed
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
