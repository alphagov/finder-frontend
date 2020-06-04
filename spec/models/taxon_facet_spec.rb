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

  let(:allowed_values) do
    {
      "level_one_taxon" => "allowed-value-1",
      "level_two_taxon" => "allowed-value-2",
    }
  end

  let(:facet_data) do
    {
      "type" => "text",
      "keys" => %w[level_one_taxon level_two_taxon],
      "name" => "Test values",
      "key" => "test_values",
      "preposition" => "of value",
      "allowed_values" => allowed_values,
    }
  end

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
        :sub_topics,
      )
    end

    it "will have a default option" do
      expect(subject.sub_topics.first[:text]).to eql("All sub-topics")
    end
  end

  describe "#sentence_fragment" do
    context "allowed value selected" do
      subject { TaxonFacet.new(facet_data, allowed_values) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("allowed-value-1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("level_one_taxon")
      end
    end

    context "disallowed value selected" do
      let(:disallowed_values) do
        {
          "level_one_taxon" => "disallowed-value-1",
          "level_two_taxon" => "disallowed-value-2",
        }
      end
      subject { TaxonFacet.new(facet_data, disallowed_values) }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#selected_taxon_value" do
    let(:level_one_taxons) do
      JSON.parse(File.read(Rails.root.join("features/fixtures/level_one_taxon.json")))
    end

    before :each do
      topic_taxonomy_has_taxons(level_one_taxons)
    end

    context "when a level one taxon is selected" do
      subject { TaxonFacet.new({}, { "level_one_taxon" => "3cf97f69-84de-41ae-bc7b-7e2cc238fa58" }) } # /environment level one taxon

      it "returns selected level one taxon value" do
        expect(subject.selected_taxon_value[:text]).to eql "Environment"
        expect(subject.selected_taxon_value[:value]).to eql "3cf97f69-84de-41ae-bc7b-7e2cc238fa58"
        expect(subject.selected_taxon_value[:sub_topics].count).to eql 2
      end
    end

    context "when a level two taxon is selected" do
      subject { TaxonFacet.new({}, { "level_two_taxon" => "52ff5c99-a17b-42c4-a9d7-2cc92cccca39" }) } # /environment/food-and-faming level two taxon

      it "returns selected level two taxon value" do
        expect(subject.selected_taxon_value[:text]).to eql "Food and farming"
        expect(subject.selected_taxon_value[:value]).to eql "52ff5c99-a17b-42c4-a9d7-2cc92cccca39"
        expect(subject.selected_taxon_value[:sub_topics].count).to eql 1
      end
    end

    context "when a topic is selected" do
      subject { TaxonFacet.new({}, { "topic" => "/environment/farming-food-grants-payments" }) }

      it "returns selected topic value" do
        expect(subject.selected_taxon_value[:text]).to eql "Farming and food grants and payments"
        expect(subject.selected_taxon_value[:value]).to eql "2368b8b1-9405-4e66-b396-a5d54b777a0a"
        expect(subject.selected_taxon_value[:sub_topics].count).to eql 1
      end
    end
  end
end
