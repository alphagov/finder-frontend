# typed: false
require "securerandom"
require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe Registries::FullTopicTaxonomyRegistry do
  include TaxonomySpecHelper
  let(:level_one_taxons) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "level_one_taxon.json")))
  }

  let(:base_path) { "/basepath" }

  before :each do
    clear_cache
  end

  after :each do
    clear_cache
  end

  describe "when topic taxonomy API is unavailable" do
    it "will return an (uncached) empty hash" do
      topic_taxonomy_api_is_unavailable
      expect(described_class.new[base_path]).to be_nil
      expect(described_class.new.taxonomy).to eql({})
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  describe "when topic taxonomy api is available" do
    before :each do
      stub_root_taxon(level_one_taxons)
      full_topic_taxonomy_has_taxons(level_one_taxons)
    end

    let(:registry) { described_class.new }
    let(:child_base_path) { "/environment/countryside-stewardship" }
    let(:first_level_base_path) { "/environment" }
    let(:child_content_id) { "013fc5e0-280c-4f73-9598-47de68f13dcd" }
    let(:first_level_content_id) { "3cf97f69-84de-41ae-bc7b-7e2cc238fa58" }

    it "can look up a child taxon by basepath" do
      fetched_document = registry[child_base_path]
      expect(fetched_document['content_id']).to eq(child_content_id)
    end

    it "can look up a level one taxon by basepath" do
      fetched_document = registry[first_level_base_path]
      expect(fetched_document['content_id']).to eq(first_level_content_id)
    end
  end

  def clear_cache
    Rails.cache.clear
  end
end
