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

    def values
      organisations
    end

  private

    def organisations_as_hash
      GovukStatsd.time("registries.organisations.request_time") do
        fetch_organisations_from_rummager
          .reject { |result| result['slug'].empty? || result['title'].empty? }
          .each_with_object({}) { |result, orgs|
            slug = result['slug']
            orgs[slug] = result.slice('title', 'slug', 'acronym')
          }
      end
    end

    def fetch_organisations_from_rummager
      params = {
        filter_format: 'organisation',
        fields: %w(title slug acronym),
        count: 1500,
        order: 'title'
      }
      response = Services.rummager.search(params)
      response['results']
    end
  end
end
