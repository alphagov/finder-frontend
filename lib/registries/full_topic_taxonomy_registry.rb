module Registries
  class FullTopicTaxonomyRegistry < Registry
    include CacheableRegistry

    delegate :[], to: :taxonomy

    def taxonomy
      @taxonomy ||= fetch_from_cache
    end

    def cache_key
      "registries/full_topic_taxonomy"
    end

    def values
      taxonomy
    end

  private

    def cacheable_data
      taxonomy_hash
    end

    def report_error
      GovukStatsd.increment("registries.full_topic_taxonomy_api_errors")
    end

    def format_taxon(taxon)
      formatted_children = Array(taxon.dig("links", "child_taxons")).map do |child|
        {
          "title" => child["title"],
          "content_id" => child["content_id"],
          "base_path" => child["base_path"],
        }
      end

      {
        taxon["content_id"] =>
        {
          "title" => taxon["title"],
          "content_id" => taxon["content_id"],
          "base_path" => taxon["base_path"],
          "children" => formatted_children,
        },
      }
    end

    def level_one_taxons
      @level_one_taxons ||= fetch_level_one_taxons_from_api
    end

    def flatten_taxonomy(taxons)
      return {} if taxons.empty?

      taxons.inject({}) do |result, taxon|
        child_taxons = taxon.dig("links", "child_taxons") || []

        taxon_hash = format_taxon(taxon)
        child_taxon_hashes = flatten_taxonomy(child_taxons)

        result.merge(taxon_hash).merge(child_taxon_hashes)
      end
    end

    def taxonomy_hash
      GovukStatsd.time("registries.full_topic_taxonomy.request_time") do
        flatten_taxonomy(level_one_taxons)
      end
    end

    def fetch_level_one_taxons_from_api
      taxons = fetch_taxon.dig("links", "level_one_taxons") || []
      taxons.map { |taxon| fetch_taxon(taxon["base_path"]) }
    end

    def fetch_taxon(base_path = "/")
      Services.cached_content_item(base_path)
    end
  end
end
