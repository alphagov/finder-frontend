# typed: strict
module Registries
  module CacheableRegistry
    extend T::Sig
    include Kernel

    sig {returns(TrueClass)}
    def can_refresh_cache?
      true
    end

    sig {returns(T::Boolean)}
    def refresh_cache
      Rails.cache.write(cache_key, cacheable_data)
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      report_error
      false
    end

    sig {returns(T::Hash)}
    def fetch_from_cache
      Rails.cache.fetch(cache_key) do
        cacheable_data
      end
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      report_error
      {}
    end

    sig {void}
    def cacheable_data
      raise NotImplementedError, "Please supply a cacheable_data method"
    end

    sig {void}
    def cache_key
      raise NotImplementedError, "Please supply a cache_key method"
    end

    sig {void}
    def report_error
      raise NotImplementedError, "Please supply a report_error method"
    end
  end
end
