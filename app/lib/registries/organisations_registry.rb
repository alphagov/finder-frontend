module Registries
  class OrganisationsRegistry
    CACHE_KEY = "registries/organisations".freeze

    def [](slug)
      organisations[slug]
    end

    def organisations
      @organisations ||= Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        organisations_as_hash
      end
    rescue GdsApi::HTTPServerError
      GovukStatsd.increment("registries.organisations_api_errors")
      {}
    end

  private

    def organisations_as_hash
      fetch_organisations_from_rummager
        .reject { |result| result['slug'].empty? || result['title'].empty? }
        .each_with_object({}) { |result, orgs|
          slug = result['slug']
          orgs[slug] = result.slice('title', 'slug')
        }
    end

    def fetch_organisations_from_rummager
      params = {
        filter_format: 'organisation',
        fields: %w(title slug),
        count: 1500
      }
      response = Services.rummager.search(params)
      response['results']
    end
  end
end
