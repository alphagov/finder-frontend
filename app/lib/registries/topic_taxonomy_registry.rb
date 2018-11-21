module Registries
  class TopicTaxonomyRegistry
    CACHE_KEY = "#{NAMESPACE}/topic_taxonomy".freeze

    def [](content_id)
      cached_taxonomy_tree[content_id]
    end

  private

    def cached_taxonomy_tree
      Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        taxonomy_tree
      end
    rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
      GovukStatsd.increment("#{NAMESPACE}.topic_taxonomy_api_errors")
      {}
    end

    def taxonomy_tree
      fetch_level_one_taxons_from_api.each_with_object({}) { |taxon, taxonomy|
        taxonomy[taxon['content_id']] = format_taxon(taxon)
      }
    end

    def format_taxon(taxon)
      {
        'title' => taxon['title'],
        'content_id' => taxon['content_id'],
        'children' => format_child_taxons(taxon)
      }
    end

    def format_child_taxons(taxon)
      children = taxon.dig('links', 'child_taxons') || []
      children.map { |child_taxon|
        format_taxon(child_taxon)
      }
    end

    def fetch_level_one_taxons_from_api
      taxons = fetch_taxon.dig('links', 'level_one_taxons') || []
      taxons.map { |taxon|
        fetch_taxon(taxon['base_path'])
      }
    end

    def fetch_taxon(base_path = '/')
      GdsApi.content_store.content_item base_path
    end
  end
end
