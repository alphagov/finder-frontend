require "spec_helper"

describe TaxonFacet do
  include TaxonomySpecHelper

  before :each do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: "allowed-value-1", title: "allowed-value-1", number_of_children: 1),
      FactoryBot.build(:level_one_taxon_hash, content_id: "allowed-value-2", title: "allowed-value-2", number_of_children: 1),
    ])
  end

  let(:allowed_values) {
    {
      "level_one_taxon" => "allowed-value-1",
      "level_two_taxon" => "allowed-value-2",
    }
  }

  let(:facet_data) {
    {
      "type" => "text",
      "keys" => %w(level_one_taxon level_two_taxon),
      "name" => "Test values",
      "key" => "test_values",
      "preposition" => "of value",
      "allowed_values" => allowed_values,
    }
  }


  describe "#topics" do
    subject { TaxonFacet.new(facet_data, allowed_values) }

    it "will return an array of topics" do
      expect(subject.topics).to be_an(Array)
      expect(subject.topics.count).to eql(4)
    end

    describe "topic items" do
      it "will have values required for rendering" do
        topic = subject.topics.second
        expect(topic.keys).to contain_exactly(
          :value,
          :text,
          :sub_topics,
          :selected,
          :data_attributes,
        )
      end
    end

    it "will have a default option" do
      expect(subject.topics.first[:text]).to eql("All topics")
    end
  end

  describe "#sub_topics" do
    subject { TaxonFacet.new(facet_data, allowed_values) }

    it "will return an array of sub-topics" do
      expect(subject.sub_topics).to be_an(Array)
      expect(subject.sub_topics.count).to eql(4)
    end

    it "will provide values required for rendering items" do
      sub_topic = subject.sub_topics.second
      expect(sub_topic.keys).to contain_exactly(
        :value,
        :text,
        :data_attributes,
        :selected,
      )
    end

    it "will have a default option" do
      expect(subject.sub_topics.first[:text]).to eql("All sub-topics")
    end
  end

  describe "#sentence_fragment" do
    context "allowed value selected" do
      subject { TaxonFacet.new(facet_data, allowed_values) }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("allowed-value-1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("level_one_taxon")
      }
    end

    context "disallowed value selected" do
      let(:disallowed_values) {
        {
          "level_one_taxon" => "disallowed-value-1",
          "level_two_taxon" => "disallowed-value-2",
        }
      }
      subject { TaxonFacet.new(facet_data, disallowed_values) }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
