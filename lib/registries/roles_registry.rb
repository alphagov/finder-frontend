module Registries
  class RolesRegistry < Registry
    include CacheableRegistry

    def [](slug)
      roles[slug]
    end

    def roles
      @roles ||= fetch_from_cache
    end

    def values
      roles
    end

    def cache_key
      "#{NAMESPACE}/roles"
    end

  private

    def report_error
      GovukStatsd.increment("registries.roles_api_errors")
    end

    def cacheable_data
      roles_as_hash
    end

    def roles_as_hash
      GovukStatsd.time("registries.roles.request_time") do
        (fetch_roles_from_rummager || {})
          .reject { |result| result.dig("value", "slug").blank? || result.dig("value", "title").blank? }
          .each_with_object({}) { |result, roles|
            slug = result["value"]["slug"]
            roles[slug] = result["value"].slice("title", "slug", "content_id")
          }
      end
    end

    def fetch_roles_from_rummager
      params = {
        facet_roles: "1500,examples:0,order:value.title",
        count: 0,
      }
      Services.rummager.search(params).dig("facets", "roles", "options")
    end
  end
end
