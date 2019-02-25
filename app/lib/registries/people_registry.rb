module Registries
  class PeopleRegistry
    CACHE_KEY = "#{NAMESPACE}/people".freeze

    def [](slug)
      people[slug]
    end

    def people
      @people ||= Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        people_as_hash
      end
    rescue GdsApi::HTTPServerError
      GovukStatsd.increment("registries.people_api_errors")
      {}
    end

    def values
      people
    end

  private

    def people_as_hash
      GovukStatsd.time("registries.people.request_time") do
        people = fetch_people_from_rummager || {}

        people.reject { |result| result.dig('value', 'slug').empty? || result.dig('value', 'title').empty? }
          .each_with_object({}) { |result, orgs|
            slug = result['value']['slug']
            orgs[slug] = result['value'].slice('title', 'slug')
          }
      end
    end

    def fetch_people_from_rummager
      params = {
        facet_people: '1500,examples:0,order:value.title',
        count: 0,
      }
      Services.rummager.search(params).dig('facets', 'people', 'options')
    end
  end
end
