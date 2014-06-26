require 'spec_helper'
require 'gds_api/test_helpers/content_api'

describe Finder do
  include ApiHelper
  include GdsApi::TestHelpers::ContentApi

  let(:name) { "CMA Cases" }
  let(:slug) { "cma-cases" }
  subject(:finder) { Finder.new(name: name, slug: slug) }

  describe ".get" do
    let (:finder_hash_from_api) { { "name" => "CMA Cases" } }
    let (:cma_case_artefact) { {
      "title" => "Competition and Markets Authority cases",
      "organisations" => []
    } }
    before {
      mock_api.stub(:get_schema).with(slug).and_return(finder_hash_from_api)
      artefact_data = artefact_for_slug(slug).merge(cma_case_artefact)
      content_api_has_an_artefact(slug, artefact_data)
    }

    it "should use FinderParser to build a finder based on the api's response" do
      FinderParser.should_receive(:parse).with(finder_hash_from_api.merge(
        "name" => "Competition and Markets Authority cases",
        "organisations" => [])).and_return(:a_built_finder)
      Finder.get(slug).should == :a_built_finder
    end
  end

  describe "#results" do
    subject(:finder) { Finder.new(slug: slug, facets: facet_collection) }

    let(:facet_params) { { some_facet: "value" } }
    let(:facet_collection) { double(:facet_collection, values: { some_facet: "value" }) }

    let(:result_set) { double(:result_set) }

    before do
      ResultSet.stub(:get).and_return(result_set)
    end

    it "queries ResultSet with slug and facet values" do
      expect(ResultSet).to receive(:get).with(slug, facet_params)

      finder.results
    end

    it "returns the result set" do
      expect(finder.results).to eq(result_set)
    end

    context "when search keywords are set" do
      before do
        finder.keywords = search_keywords
      end

      let(:search_keywords) { double(:search_keywords) }

      it "includes the search term in the ResultSet query" do
        expect(ResultSet).to receive(:get)
          .with(slug, hash_including("keywords" => search_keywords))

        finder.results
      end
    end
  end
end
