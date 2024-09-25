require "securerandom"
require "spec_helper"

RSpec.describe Registries::TopicTaxonomyRegistry do
  include TaxonomySpecHelper

  let(:content_id_one) { SecureRandom.uuid }
  let(:content_id_two) { SecureRandom.uuid }
  let(:top_level_taxon_one) { FactoryBot.build(:level_one_taxon_hash, content_id: content_id_one, title: content_id_one) }
  let(:top_level_taxon_two) { FactoryBot.build(:level_one_taxon_hash, content_id: content_id_two, title: content_id_two) }
  let(:top_level_taxon_three) { FactoryBot.build(:level_one_taxon_hash, content_id: SecureRandom.uuid, title: "Alpha topic", phase: "alpha") }

  before do
    Rails.cache.clear
  end

  describe "when topic taxonomy API is unavailable" do
    it "returns an (uncached) empty hash" do
      topic_taxonomy_api_is_unavailable
      expect(described_class.new[content_id_one]).to be_nil
      expect(described_class.new.taxonomy_tree).to eql({})
      expect(Rails.cache.fetch(::Registries::TopicTaxonomyRegistry.new.cache_key)).to be_nil
    end
  end

  describe "when topic taxonomy api is available" do
    subject(:registry) { described_class.new }

    before do
      topic_taxonomy_has_taxons([top_level_taxon_one, top_level_taxon_two, top_level_taxon_three])
    end

    it "provides the taxonomy tree not including those in the alpha phase" do
      expect(registry.taxonomy_tree.keys).to contain_exactly(content_id_one, content_id_two)
    end

    it "fetches an expanded topic taxon by content_id" do
      fetched_document = registry[content_id_one]
      expect(fetched_document["content_id"]).to eq(content_id_one)
      expect(fetched_document["title"]).to eq(top_level_taxon_one["title"])

      fetched_document = registry[content_id_two]
      expect(fetched_document["content_id"]).to eq(content_id_two)
      expect(fetched_document["title"]).to eq(top_level_taxon_two["title"])
    end
  end
end
