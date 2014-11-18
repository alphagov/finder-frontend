require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore

describe FinderParser do
  context "with a finder hash" do
    let(:finder_hash) { {
      "name" => "CMA Cases",
      "slug" => "finder-slug",
      "document_noun" => "case",
      "facets" => :facet_hashes,
    } }

    let(:cma_cases_content_item) { {
      base_path: "/cma-cases",
      title: "CMA Cases",
      description: "",
      format: "finder",
      need_ids: [],
      details: {
        beta: false,
      },
      links: {
        organisations: [
          {
            title: "Competition And Markets Authority",
            base_path: "/government/organisations/competition-and-markets-authority",
          }
        ],
        topics: [],
        related: [],
      }
    }.with_indifferent_access }

    before {
      FacetCollectionParser.stub(:parse).with(:facet_hashes).and_return(:a_facet_collection)
    }
    subject { FinderParser.parse(cma_cases_content_item, finder_hash) }

    specify { subject.name.should == "CMA Cases" }
    specify { subject.slug.should == "finder-slug" }
    specify { subject.document_noun.should == "case" }
    specify { subject.facets.should == :a_facet_collection }
  end
end
