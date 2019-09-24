require "spec_helper"

describe HiddenFacet do
  let(:facet_data) {
    {
      "key" => "test_facet",
      "name" => "Test facet",
      "preposition" => "of value",
      "allowed_values" => [{ "value" => "hidden_value" }],
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
      it "returns the value" do
        facet = HiddenFacet.new(facet_data, "hidden_value")
        expect(facet.query_params).to eql("test_facet" => %w[hidden_value])
      end
    end
    context "invalid value selected" do
      it "removes the invalid values" do
        facet = HiddenFacet.new(facet_data, "not_allowed_value")
        expect(facet.query_params).to eql("test_facet" => [])
      end
    end
    context "no allowed values specified" do
      let(:facet_data) {
        {
          "key" => "test_facet",
          "name" => "Test facet",
          "preposition" => "of value",
          "allowed_values" => [],
        }
      }
      it "returns the values without validation" do
        facet = HiddenFacet.new(facet_data, "hidden_value")
        expect(facet.query_params).to eql("test_facet" => %w[hidden_value])
      end
    end
  end
end
