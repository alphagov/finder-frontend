require "spec_helper"
require "helpers/taxonomy_spec_helper"

describe TaxonFacet do
  include TaxonomySpecHelper

  before do
    topic_taxonomy_has_taxons(allowed_values)
  end

  let(:allowed_values) { ["allowed-value-1", "allowed-value-2"] }

  let(:facet_data) {
    {
      'type' => "text",
      'name' => "Test values",
      'key' => "test_values",
      'preposition' => "of value",
      'allowed_values' => allowed_values,
    }
  }

  subject { TaxonFacet.new(facet_data) }

  describe "#sentence_fragment" do
    before do
      subject.value = value
    end

    context "allowed value selected" do
      let(:value) { allowed_values.first }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("allowed-value-1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("test_values")
      }
    end

    context "disallowed value selected" do
      let(:value) { "disallowed-value-1" }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
