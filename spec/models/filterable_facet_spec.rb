require 'spec_helper'

describe FilterableFacet do
  let(:facet_struct) {
    OpenStruct.new(
      key: "test_facet",
      name: "Test facet",
      preposition: "of value"
    )
  }

  let(:facet_class) { FilterableFacet }
  subject { facet_class.new(facet_struct) }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { subject.to_partial_path.should == "filterable_facet" }
    end

    context "with another kind of facet" do
      class ExampleFacet < FilterableFacet; end
      let(:facet_class) { ExampleFacet }
      specify { subject.to_partial_path.should == "example_facet" }
    end
  end
end
