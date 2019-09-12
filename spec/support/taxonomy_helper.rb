require "gds_api/test_helpers/content_store"
require "registries/base_registries"

module TaxonomySpecHelper
  include ::GdsApi::TestHelpers::ContentStore

  def topic_taxonomy_api_is_unavailable
    content_store_isnt_available
  end

  def topic_taxonomy_has_taxons(level_one_taxon_hashes = FactoryBot.build_list(:level_one_taxon_hash, 2, number_of_children: 2))
    has_taxons(level_one_taxon_hashes)
    has_root_taxon_with(level_one_taxon_hashes)
  end

private

  def has_root_taxon_with(level_one_taxon_hashes)
    root_taxon_hash = FactoryBot.build(:root_taxon_hash, level_one_taxon_hashes: level_one_taxon_hashes)
    content_store_has_item("/", root_taxon_hash)
  end

  def has_taxons(taxon_hashes)
    return if taxon_hashes.nil?

    taxon_hashes.each do |taxon_hash|
      content_store_has_item(taxon_hash["base_path"], taxon_hash)
      has_taxons(taxon_hash.dig("links", "child_taxons"))
    end
  end
end
