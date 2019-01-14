require "spec_helper"
require "helpers/taxonomy_spec_helper"

describe TaxonFacet do
  include TaxonomySpecHelper

  before do
    topic_taxonomy_has_taxons(%w(allowed-value-1 allowed-value-2))
  end

  let(:allowed_values) {
    {
      "level_one_taxon" => "allowed-value-1",
      "level_two_taxon" => "allowed-value-2",
    }
  }

  let(:facet_data) {
    {
      'type' => "text",
      "keys" => %w(level_one_taxon level_two_taxon),
      'name' => "Test values",
      'key' => "test_values",
      'preposition' => "of value",
      'allowed_values' => allowed_values,
    }
  }

  subject { TaxonFacet.new(facet_data) }

  describe "#topics" do
    before do
      subject.value = allowed_values
    end

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
          :data_attributes
        )
      end
    end

    it "will have a default option" do
      expect(subject.topics.first[:text]).to eql('All topics')
    end
  end

  describe "#sub_topics" do
    before do
      subject.value = allowed_values
    end

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
        :selected
      )
    end

    it "will have a default option" do
      expect(subject.sub_topics.first[:text]).to eql('All sub-topics')
    end
  end

  describe "#sentence_fragment" do
    before do
      subject.value = value
    end

    context "allowed value selected" do
      let(:value) { allowed_values }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("allowed-value-1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("level_one_taxon")
      }
    end

    context "disallowed value selected" do
      let(:value) { "disallowed-value-1" }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
