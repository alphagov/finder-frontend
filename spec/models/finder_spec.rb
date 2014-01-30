require 'spec_helper'

describe Finder do
  let(:name) { "CMA Cases" }
  let(:slug) { "finder-slug" }
  let(:api) { FinderApi.new(slug) }
  subject { Finder.new(name: name, api: api, slug: slug) }

  describe ".from_hash" do
    let(:finder_hash) { {
      "name" => name,
      "slug" => slug,
      "facets" => :facet_collection_hash
    } }
    subject { Finder.from_hash(finder_hash) }
    before do
      FacetCollection.stub(:from_hash).with("facets" => :facet_collection_hash).and_return(:a_facet_collection)
    end

    specify { subject.name.should == "CMA Cases" }
    specify { subject.slug.should == "finder-slug" }
    specify { subject.facets.should == :a_facet_collection }
  end

  describe "#results" do
    let(:facet_params) { :some_facet_values }
    let(:facet_collection) { OpenStruct.new(values: facet_params) }
    subject { Finder.new(api: api, facets: facet_collection) }

    before do
      ResultSet.stub(:get).with(api, :some_facet_values).and_return(:a_result_set)
    end

    specify { subject.results.should == :a_result_set }
  end

  describe "#get" do
    before { api.stub(:get_finder).and_return("name" => "CMA Cases") }

    specify { Finder.get(api).should be_a(Finder) }
    specify { Finder.get(api).name.should == "CMA Cases" }
    specify { Finder.get(api).api.should == api }
  end

  describe "#get_with_facet_values" do
    let(:facet_collection) { FacetCollection.new }
    before {
      FacetCollection.stub(:from_hash).and_return(facet_collection)
      api.stub(:get_finder).and_return("name" => "CMA Cases")
    }

    it "should get the finder and then populate its facets' values" do
      facet_collection.should_receive(:values=).with(:some_facet_values)
      Finder.get_with_facet_values(api, :some_facet_values).should be_a(Finder)
    end
  end
end
