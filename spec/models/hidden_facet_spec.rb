# typed: false
require 'spec_helper'

describe HiddenFacet do
  let(:facet_data) {
    {
      'key' => "test_facet",
      'name' => "Test facet",
      'preposition' => "of value",
      'allowed_values' => [{ "value" => "hidden_value" }]
    }
  }

  let(:facet_class) { HiddenFacet }
  subject { facet_class.new(facet_data, nil) }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { expect(subject.to_partial_path).to eql("hidden_facet") }
    end
  end

  describe "#query_params" do
    context "value selected" do
      subject { HiddenFacet.new(facet_data, "hidden_value") }
      specify {
        expect(subject.query_params).to eql("test_facet" => %w[hidden_value])
      }
    end
  end
end
