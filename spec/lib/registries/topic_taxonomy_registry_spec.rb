require "securerandom"
require 'spec_helper'
require "gds_api/test_helpers/content_store"

RSpec.describe Registries::TopicTaxonomyRegistry do
  include ::GdsApi::TestHelpers::ContentStore

  let(:content_id_one) { "top-level-taxon-one" }
  let(:content_id_two) { "top-level-taxon-two" }
  let(:top_level_taxon_one) { top_level_taxon(content_id_one) }
  let(:top_level_taxon_two) { top_level_taxon(content_id_two) }

  describe "when topic taxonomy API is unavailable" do
    it "will return an (uncached) empty hash" do
      clear_cache
      topic_taxonomy_api_is_unavailable
      expect(described_class.new[content_id_one]).to be_nil
      expect(Rails.cache.fetch(described_class::CACHE_KEY)).to be_nil
    end
  end


  describe "when topic taxonomy api is available" do
    before :each do
      clear_cache
      topic_taxonomy_has_taxons
    end

    after { clear_cache }

    subject(:registry) { described_class.new }

    it "will fetch an expanded topic taxon by content_id" do
      fetched_document = registry[content_id_one]
      expect(fetched_document['content_id']).to eq(top_level_taxon_one['content_id'])
      expect(fetched_document['title']).to eq(top_level_taxon_one['title'])

      fetched_document = registry[content_id_two]
      expect(fetched_document['content_id']).to eq(top_level_taxon_two['content_id'])
      expect(fetched_document['title']).to eq(top_level_taxon_two['title'])
    end
  end

  def topic_taxonomy_api_is_unavailable
    stub_request(:get, topic_taxonomy_endpoint).to_return(status: 500)
  end

  def topic_taxonomy_has_taxons
    stub_request(:get, topic_taxonomy_endpoint).
      to_return(status: 200, body: root_taxon.to_json)

    stub_request(:get, "#{topic_taxonomy_endpoint}#{content_id_one}").
      to_return(status: 200, body: top_level_taxon(content_id_one).to_json)

    stub_request(:get, "#{topic_taxonomy_endpoint}#{content_id_two}").
      to_return(status: 200, body: top_level_taxon(content_id_two).to_json)
  end

  def topic_taxonomy_endpoint
    "#{Plek.current.find('content-store')}/content/"
  end

  def clear_cache
    Rails.cache.delete(described_class::CACHE_KEY)
  end

  def root_taxon
    {
      "links" => {
        "level_one_taxons" => [ top_level_taxon_one, top_level_taxon_two ]
      }
    }
  end

  def top_level_taxon(content_id)
    {
      'base_path' => "/#{content_id}",
      'title' => "Top level taxon #{content_id}",
      'content_id' => content_id,
      'links' => {
        'child_taxons' => [ sub_taxon, sub_taxon ]
      }
    }
  end

  def sub_taxon
    {
      'base_path' => "/subtaxon",
      'title' => "subtaxon",
      'content_id' => "subtaxon",
      'links' => {}
    }
  end
end
