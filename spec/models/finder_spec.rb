require 'spec_helper'

describe Finder do
  include ApiHelper

  let(:name) { "CMA Cases" }
  let(:slug) { "finder-slug" }
  subject { Finder.new(name: name, slug: slug) }

  describe ".get" do
    let (:finder_hash_from_api) { { "name" => "CMA Cases" } }
    before {
      mock_api.stub(:get_finder).with(slug).and_return(finder_hash_from_api)
    }

    it "should use FinderParser to build a finder based on the api's response" do
      FinderParser.should_receive(:parse).with(finder_hash_from_api).and_return(:a_built_finder)
      Finder.get(slug).should == :a_built_finder
    end
  end

  describe "#results" do
    let(:facet_params) { :some_facet_values }
    let(:facet_collection) { OpenStruct.new(values: facet_params) }
    subject { Finder.new(slug: slug, facets: facet_collection) }

    before do
      ResultSet.stub(:get).with(slug, :some_facet_values).and_return(:a_result_set)
    end

    specify { subject.results.should == :a_result_set }
  end
end
