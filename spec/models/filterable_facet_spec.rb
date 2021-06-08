require "spec_helper"

class ExampleFacet < FilterableFacet; end

describe FilterableFacet do
  let(:facet_data) do
    {
      "key" => "test_facet",
      "name" => "Test facet",
      "preposition" => "of value",
    }
  end

  let(:facet_class) { FilterableFacet }
  subject { facet_class.new(facet_data) }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { expect(subject.to_partial_path).to eql("filterable_facet") }
    end

    context "with another kind of facet" do
      let(:facet_class) { ExampleFacet }
      specify { expect(subject.to_partial_path).to eql("example_facet") }
    end
  end

  describe "#preposition" do
    let(:default_preposition) do
      facet_class.new(
        "key" => "test_facet",
        "name" => "Facet without preposition",
      )
    end

    it "has a default preposition" do
      expect(default_preposition.preposition).to eq("related to")
    end

    it "has a preposition specified in the facet content" do
      expect(subject.preposition).to eq(facet_data["preposition"])
    end
  end
end
