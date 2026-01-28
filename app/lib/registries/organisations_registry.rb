module Registries
  class OrganisationsRegistry < Registry
    include CacheableRegistry

    delegate :[], to: :organisations

    def organisations
      @organisations ||= fetch_from_cache
    end

    def values
      organisations
    end

    def cache_key
      "registries/organisations"
    end

  private

    def report_error
      GovukStatsd.increment("registries.organisations_api_errors")
    end

    def cacheable_data
      organisations_as_hash
    end

    def organisations_as_hash
      GovukStatsd.time("registries.organisations.request_time") do
        fetch_organisations_from_rummager
          .reject { |result| result["slug"].blank? || result["title"].blank? }
          .sort_by { |result| result["title"].sub("Closed organisation: ", "ZZ").upcase }
          .each_with_object({}) do |result, orgs|
            slug = result["slug"]
            orgs[slug] = result.slice("title", "slug", "acronym", "content_id")
          end
      end
    end

    def fetch_organisations_from_rummager
      params = {
        filter_format: "organisation",
        fields: %w[title slug acronym content_id],
        count: 1500,
        order: "title",
      }
      response = Services.rummager.search(params)
      response["results"]
    end
  end
end
