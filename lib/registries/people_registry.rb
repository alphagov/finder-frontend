module Registries
  class PeopleRegistry < Registry
    include CacheableRegistry

    def [](slug)
      people[slug]
    end

    def people
      @people ||= fetch_from_cache
    end

    def values
      people
    end

    def cache_key
      "#{NAMESPACE}/people"
    end

  private

    def report_error
      GovukStatsd.increment("registries.people_api_errors")
    end

    def cacheable_data
      people_as_hash
    end

    def people_as_hash
      GovukStatsd.time("registries.people.request_time") do
        people = fetch_people_from_rummager || {}

        people.reject { |result| result.dig("value", "slug").blank? || result.dig("value", "title").blank? }
          .each_with_object({}) { |result, orgs|
            slug = result["value"]["slug"]
            orgs[slug] = result["value"].slice("title", "slug", "content_id")
          }
      end
    end

    def fetch_people_from_rummager
      params = {
        facet_people: "1500,examples:0,order:value.title",
        count: 0,
      }
      Services.rummager.search(params).dig("facets", "people", "options")
    end
  end
end
