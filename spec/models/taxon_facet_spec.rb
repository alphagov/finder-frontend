require "spec_helper"

describe TaxonFacet do
  include TaxonomySpecHelper

  subject { described_class.new(facet_data, allowed_values) }

  before do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: "allowed-value-1", title: "allowed-value-1", child_taxons: [
        FactoryBot.build(:taxon_hash, content_id: "allowed-child-value", title: "allowed-child-value"),
      ]),
      FactoryBot.build(:level_one_taxon_hash, content_id: "allowed-value-2", title: "allowed-value-2", number_of_children: 1),
    ])
  end

  let(:allowed_values) do
    {
      "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21",
      "level_two_taxon" => "0133b1b3-9ecd-48ad-b226-538b46a17ff4",
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

  it { is_expected.to be_user_visible }

  describe "#topics" do
    subject { described_class.new(facet_data, allowed_values) }

    it "returns an array of topics" do
      expect(subject.topics).to be_an(Array)
      expect(subject.topics.count).to be(22) # Real top level taxon count
    end

    describe "topic items" do
      it "has values required for rendering" do
        topic = subject.topics.second
        expect(topic.keys).to contain_exactly(
          :value,
          :text,
          :subtopics,
          :selected,
        )
      end
    end

    it "has a default option" do
      expect(subject.topics.first[:text]).to eql("All topics")
    end
  end

  describe "#subtopics" do
    subject { described_class.new(facet_data, allowed_values) }

    it "returns an array of subtopics" do
      expect(subject.subtopics).to be_an(Array)
      expect(subject.subtopics.count).to be(209)
    end

    it "provides values required for rendering items" do
      subtopic = subject.subtopics.second
      expect(subtopic.keys).to contain_exactly(
        :value,
        :text,
        :data_attributes,
        :selected,
      )
    end

    it "has a default option" do
      expect(subject.subtopics.first[:text]).to eql("All subtopics")
    end
  end

  describe "#sentence_fragment" do
    context "allowed value selected" do
      subject { described_class.new(facet_data, allowed_values) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Work")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("level_one_taxon")
      end
    end

    context "disallowed value selected" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "disallowed-value-1",
          "level_two_taxon" => "disallowed-value-2",
        }
      end

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#applied_filters" do
    context "only level one selected" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
        }
      end

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Topic",
            label: "Work",
            query_params: {
              "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
            },
          },
        ])
      end
    end

    context "both level one and two selected" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
          "level_two_taxon" => "d2005b89-352f-4896-aced-1d17504330e6", # /education/education-of-disadvantaged-children
        }
      end

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Topic",
            label: "Work",
            query_params: {
              "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
              "level_two_taxon" => "d2005b89-352f-4896-aced-1d17504330e6", # /education/education-of-disadvantaged-children
            },
          },
          {
            name: "Subtopic",
            label: "Education of disadvantaged children",
            query_params: { "level_two_taxon" => "d2005b89-352f-4896-aced-1d17504330e6" },
          },
        ])
      end
    end

    context "disallowed value selected" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "disallowed-value-1",
          "level_two_taxon" => "disallowed-value-2",
        }
      end

      specify { expect(subject.applied_filters).to be_empty }
    end
  end

  describe "#status_text" do
    context "when no filters are applied" do
      let(:allowed_values) { {} }

      it "returns nil" do
        expect(subject.status_text).to be_nil
      end
    end

    context "when a topic filter is applied" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
        }
      end

      it "returns that one topic is selected" do
        expect(subject.status_text).to eql("1 selected")
      end
    end

    context "when a subtopic filter is applied" do
      let(:allowed_values) do
        {
          "level_one_taxon" => "d0f1e5a3-c8f4-4780-8678-994f19104b21", # /work
          "level_two_taxon" => "d2005b89-352f-4896-aced-1d17504330e6", # /education/education-of-disadvantaged-children
        }
      end

      it "returns that two topics are selected" do
        expect(subject.status_text).to eql("2 selected")
      end
    end
  end
end
