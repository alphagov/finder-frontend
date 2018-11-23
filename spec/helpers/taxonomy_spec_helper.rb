module TaxonomySpecHelper
  CONTENT_ID_1 = "top-level-taxon-one".freeze
  CONTENT_ID_2 = "top-level-taxon-two".freeze

  def topic_taxonomy_api_is_unavailable
    stub_request(:get, topic_taxonomy_endpoint).to_return(status: 500)
  end

  def topic_taxonomy_has_taxons(taxon_ids = [CONTENT_ID_1, CONTENT_ID_2])
    clear_taxon_cache

    taxons = []

    taxon_ids.map { |id|
      taxon = top_level_taxon(id)
      taxons.unshift(taxon)
      stub_request(:get, "#{topic_taxonomy_endpoint}#{id}").
        to_return(status: 200, body: taxon.to_json)
    }

    stub_request(:get, topic_taxonomy_endpoint).
      to_return(status: 200, body: root_taxon(taxons).to_json)

    taxons
  end

  def topic_taxonomy_endpoint
    "#{Plek.current.find('content-store')}/content/"
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

  def top_level_taxon(content_id)
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
