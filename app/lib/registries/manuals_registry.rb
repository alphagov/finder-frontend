module Registries
  class ManualsRegistry
    CACHE_KEY = 'registries/manuals'.freeze

    def [](base_url)
      manuals[base_url]
    end

    def values
      manuals
    end

  private

    def manuals
      @manuals ||= Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        manuals_as_hash
      end
    rescue GdsApi::HTTPServerError
      GovukStatsd.increment('registries.manuals_api_errors')
      {}
    end

    def manuals_as_hash
      GovukStatsd.time('registries.manuals.request_time') do
        fetch_manuals_from_rummager
          .reject { |manual| manual['_id'].empty? || manual['title'].empty? }
          .each_with_object({}) { |manual, manuals|
            manuals[manual['_id']] = { 'title' => manual['title'], 'slug' => manual['_id'] }
          }
      end
    end

    def fetch_manuals_from_rummager
      params = {
          filter_document_type: %w(manual service_manual_homepage service_manual_guide),
          fields: %w(title),
          count: 1500,
      }
      Services.rummager.search(params)['results']
    end
  end
end
