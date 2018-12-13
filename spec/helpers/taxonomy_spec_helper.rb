require "gds_api/test_helpers/content_store"

module TaxonomySpecHelper
  include ::GdsApi::TestHelpers::ContentStore

  CONTENT_ID_1 = SecureRandom.uuid.freeze
  CONTENT_ID_2 = SecureRandom.uuid.freeze

  def topic_taxonomy_api_is_unavailable
    content_store_isnt_available
  end

  def topic_taxonomy_has_taxons(taxon_ids = [CONTENT_ID_1, CONTENT_ID_2])
    clear_taxon_cache

    taxons = []

    taxon_ids.map { |id|
      taxon = level_one_taxon(id)
      taxons.unshift(taxon)

      content_store_has_item("/#{id}", taxon)
    }

    content_store_has_item("/", root_taxon(taxons))

    taxons
  end

  def clear_taxon_cache
    Rails.cache.delete(taxon_cache_key)
  end

  def taxon_cache_key
    'test/registries/topic_taxonomy'
  end

  def root_taxon(taxons)
    {
      "links" => {
        "level_one_taxons" => taxons
      }
    }
  end

  def level_one_taxon(content_id)
    {
      'base_path' => "/#{content_id}",
      'title' => content_id,
      'content_id' => content_id,
      'links' => {
        'child_taxons' => [{
          'base_path' => "/subtaxon",
          'title' => "subtaxon",
          'content_id' => "subtaxon",
          'links' => {}
        }]
      }
    }
  end
end
