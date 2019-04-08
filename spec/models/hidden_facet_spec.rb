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
end
