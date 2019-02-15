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
      fetch_people_from_rummager
        .reject { |result| result['slug'].empty? || result['title'].empty? }
        .each_with_object({}) { |result, orgs|
          slug = result['slug']
          orgs[slug] = result.slice('title', 'slug')
        }
    end

    def fetch_people_from_rummager
      params = {
        filter_format: 'person',
        fields: %w(title slug),
        count: 1500,
        order: 'title'
      }
      Services.rummager.search_enum(params, page_size: 1500)
    end
  end
end
