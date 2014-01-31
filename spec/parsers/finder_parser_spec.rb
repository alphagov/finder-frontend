require 'spec_helper'

describe FinderParser do
  context "with a finder hash" do
    let(:finder_hash) { {
      "name" => "CMA Cases",
      "slug" => "finder-slug",
      "facets" => :facet_hashes
    } }
    before {
      FacetCollectionParser.stub(:parse).with(:facet_hashes).and_return(:a_facet_collection)
    }
    subject { FinderParser.parse(finder_hash) }

    specify { subject.name.should == "CMA Cases" }
    specify { subject.slug.should == "finder-slug" }
    specify { subject.facets.should == :a_facet_collection }
  end
end
