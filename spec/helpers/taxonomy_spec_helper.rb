# typed: true
require "gds_api/test_helpers/content_store"

module TaxonomySpecHelper
  include ::GdsApi::TestHelpers::ContentStore

  CONTENT_ID_1 = SecureRandom.uuid.freeze
  CONTENT_ID_2 = SecureRandom.uuid.freeze

  def default_taxons
    [
      {
        content_id: CONTENT_ID_1,
        title: 'Herbology',
      },
      {
        content_id: CONTENT_ID_2,
        title: 'Magical Education',
      }
    ]
  end

  def topic_taxonomy_api_is_unavailable
    content_store_isnt_available
  end

  def topic_taxonomy_has_taxons(topics = default_taxons)
    clear_taxon_cache

    taxons = topics.map { |topic|
      taxon = level_one_taxon(topic)
      content_store_has_item("/#{topic[:content_id]}", taxon)
      taxon
    }

    content_store_has_item("/", root_taxon(taxons))

    taxons
  end

  def stub_root_taxon(taxons)
    content_store_has_item("/", root_taxon(taxons))
  end

  def full_topic_taxonomy_has_taxons(taxons)
    taxons.each do |taxon|
      content_store_has_item(taxon['base_path'], taxon)
      unless taxon['links'].empty?
        full_topic_taxonomy_has_taxons(taxon['links']['child_taxons'])
      end
    end
  end

  def clear_taxon_cache
    Rails.cache.delete(taxon_cache_key)
  end

  def clear_full_taxon_cache
    Rails.cache.delete('registries/full_topic_taxonomy')
  end

  def taxon_cache_key
    'registries/topic_taxonomy'
  end

  def root_taxon(taxons)
    {
      "links" => {
        "level_one_taxons" => taxons
      }
    }
  end

  def level_one_taxon(topic)
    {
      'base_path' => "/#{topic[:content_id]}",
      'title' => topic[:title],
      'content_id' => topic[:content_id],
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
