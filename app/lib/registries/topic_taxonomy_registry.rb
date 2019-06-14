module Registries
  class TopicTaxonomyRegistry
    CACHE_KEY = "registries/topic_taxonomy".freeze

    def [](content_id)
      taxonomy_tree[content_id]
    end

    def taxonomy_tree
      @taxonomy_tree ||= Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        taxonomy_tree_as_hash
      end
    rescue GdsApi::HTTPServerError
      GovukStatsd.increment("registries.topic_taxonomy_api_errors")
      {}
    end

  private

    def taxonomy_tree_as_hash
      GovukStatsd.time("registries.topic_taxonomy.request_time") do
        fetch_level_one_taxons_from_api.each_with_object({}) { |taxon, taxonomy|
          taxonomy[taxon['content_id']] = format_taxon(taxon)
        }
      end
    end

    def format_taxon(taxon, parent_id = nil)
      {
        'title' => taxon['title'],
        'content_id' => taxon['content_id'],
        'children' => format_child_taxons(taxon),
        'parent' => parent_id
      }
    end

    def format_child_taxons(taxon)
      children = taxon.dig('links', 'child_taxons') || []
      formatted_children = children.map { |child_taxon|
        format_taxon(child_taxon, taxon['content_id'])
      }

      formatted_children.sort_by { |child_taxon| child_taxon['title'] }
    end

    def fetch_level_one_taxons_from_api
      taxons = fetch_taxon.dig('links', 'level_one_taxons') || []
      sorted = taxons.sort_by { |taxon| taxon['title'] }
      sorted.map { |taxon| fetch_taxon(taxon['base_path']) }
    end

    def fetch_taxon(base_path = '/')
      Services.cached_content_item(base_path)
    end
  end
end
