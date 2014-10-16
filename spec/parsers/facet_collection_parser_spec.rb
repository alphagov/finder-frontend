require 'rails_helper'

describe FacetCollectionParser do
  context "with an array of facet hashes" do
    let(:facet_hashes) { [
      :a_facet_hash,
      :another_facet_hash
    ] }
    before {
      FacetParser.stub(:parse).with(:a_facet_hash).and_return(:a_facet)
      FacetParser.stub(:parse).with(:another_facet_hash).and_return(:another_facet)
    }
    subject { FacetCollectionParser.parse(facet_hashes) }

    specify { subject.should be_a FacetCollection }
    specify { subject.facets.should == [:a_facet, :another_facet] }
  end
end
