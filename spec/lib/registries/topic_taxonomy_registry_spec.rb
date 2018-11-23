require "securerandom"
require 'spec_helper'
require "gds_api/test_helpers/content_store"
require "helpers/taxonomy_spec_helper"

RSpec.describe Registries::TopicTaxonomyRegistry do
  include ::GdsApi::TestHelpers::ContentStore
  include TaxonomySpecHelper

  let(:content_id_one) { "top-level-taxon-one" }
  let(:content_id_two) { "top-level-taxon-two" }
  let(:top_level_taxon_one) { top_level_taxon(content_id_one) }
  let(:top_level_taxon_two) { top_level_taxon(content_id_two) }

  describe "when topic taxonomy API is unavailable" do
    it "will return an (uncached) empty hash" do
      clear_taxon_cache
      topic_taxonomy_api_is_unavailable
      expect(described_class.new[content_id_one]).to be_nil
      expect(described_class.new.taxonomy_tree).to eql({})
      expect(Rails.cache.fetch(taxon_cache_key)).to be_nil
    end
  end

  describe "when topic taxonomy api is available" do
    before :each do
      clear_taxon_cache
      topic_taxonomy_has_taxons([content_id_one, content_id_two])
    end

    after { clear_taxon_cache }

    subject(:registry) { described_class.new }

    it "will provide the taxonomy tree" do
      expect(registry.taxonomy_tree.keys).to match_array([content_id_one, content_id_two])
    end

    it "will fetch an expanded topic taxon by content_id" do
      fetched_document = registry[content_id_one]
      expect(fetched_document['content_id']).to eq(content_id_one)
      expect(fetched_document['title']).to eq(top_level_taxon_one['title'])

      fetched_document = registry[content_id_two]
      expect(fetched_document['content_id']).to eq(content_id_two)
      expect(fetched_document['title']).to eq(top_level_taxon_two['title'])
    end
  end

  def topic_taxonomy_api_is_unavailable
    stub_request(:get, topic_taxonomy_endpoint).to_return(status: 500)
  end
end
