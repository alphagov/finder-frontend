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
      {
        taxon["content_id"] =>
        {
          "title" => taxon["title"],
          "base_path" => taxon["base_path"],
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
      taxons.map do |taxon|
        fetch_taxon(taxon["base_path"])
      end
    end

    def fetch_taxon(base_path = "/")
      if base_path == "/"
        path = "config/content/_homepage.json"
      else
        path = "config/content/#{base_path.gsub('/', '_')}.json"
      end
      JSON.parse(File.read(path))
    end
  end
end
