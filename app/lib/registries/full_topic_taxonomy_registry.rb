module Registries
  class FullTopicTaxonomyRegistry
    CACHE_KEY = "registries/full_topic_taxonomy".freeze

    def [](base_path)
      taxonomy[base_path]
    end

    def refresh_cache
      Rails.cache.write(CACHE_KEY, taxonomy_hash)
    rescue GdsApi::HTTPServerError
      report_error
      raise RefreshOperationFailed, "Could not update #{CACHE_KEY} cache due to HTTPServerError"
    end

    def taxonomy
      @taxonomy ||= Rails.cache.fetch(CACHE_KEY) do
        taxonomy_hash
      end
    rescue GdsApi::HTTPServerError
      report_error
      {}
    end

  private

    def report_error
      GovukStatsd.increment("#{NAMESPACE}.full_topic_taxonomy_api_errors")
    end

    def format_taxon(taxon)
      {
        'title' => taxon['title'],
        'content_id' => taxon['content_id']
      }
    end

    def level_one_taxons
      @level_one_taxons ||= fetch_level_one_taxons_from_api
    end

    def flatten_taxonomy(taxons, output_hash)
      taxons.each do |taxon|
        output_hash[taxon['base_path']] = format_taxon(taxon)
        unless taxon.dig('links', 'child_taxons').nil?
          flatten_taxonomy(taxon['links']['child_taxons'], output_hash)
        end
      end
    end

    def taxonomy_hash
      GovukStatsd.time("registries.full_topic_taxonomy.request_time") do
        output_hash = {}
        flatten_taxonomy(level_one_taxons, output_hash)
        output_hash
      end
    end

    def fetch_level_one_taxons_from_api
      taxons = fetch_taxon.dig('links', 'level_one_taxons') || []
      taxons.map { |taxon| fetch_taxon(taxon['base_path']) }
    end

    def fetch_taxon(base_path = '/')
      Services.cached_content_item(base_path)
    end
  end
end
