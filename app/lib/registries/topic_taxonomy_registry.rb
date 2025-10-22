module Registries
  class TopicTaxonomyRegistry < Registry
    include CacheableRegistry

    delegate :[], to: :taxonomy_tree

    def taxonomy_tree
      @taxonomy_tree ||= fetch_from_cache
    end

    def values
      taxonomy_tree
    end

    def cache_key
      "#{NAMESPACE}/topic_taxonomy"
    end

  private

    def report_error
      GovukStatsd.increment("registries.topic_taxonomy_api_errors")
    end

    def cacheable_data
      taxonomy_tree_as_hash
    end

    def taxonomy_tree_as_hash
      GovukStatsd.time("registries.topic_taxonomy.request_time") do
        fetch_level_one_taxons_from_api.each_with_object({}) do |taxon, taxonomy|
          taxonomy[taxon["content_id"]] = format_taxon(taxon)
        end
      end
    end

    def format_taxon(taxon, parent_id = nil)
      {
        "title" => taxon["title"],
        "content_id" => taxon["content_id"],
        "children" => format_child_taxons(taxon),
        "parent" => parent_id,
      }
    end

    def format_child_taxons(taxon)
      children = taxon.dig("links", "child_taxons") || []

      children
        .reject { |child_taxon| child_taxon["phase"] == "alpha" }
        .map { |child_taxon| format_taxon(child_taxon, taxon["content_id"]) }
        .sort_by { |child_taxon| child_taxon["title"] }
    end

    def fetch_level_one_taxons_from_api
      taxons = fetch_taxon.dig("links", "level_one_taxons") || []
      taxons
        .reject { |taxon| taxon["phase"] == "alpha" }
        .sort_by { |taxon| taxon["title"] }
        .map { |taxon| fetch_taxon(taxon["base_path"]) }
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
