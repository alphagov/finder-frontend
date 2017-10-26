require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore

describe SearchController, type: :controller do
  include GovukAbTesting::RspecHelpers
  render_views

  before do
    content_store_has_item(
      '/search',
        base_path: '/search',
        title: 'Search'
    )

    rummager_response = %|{
        "results": [],
        "total": 0,
        "start": 0,
        "facets": {},
        "suggested_queries": []
      }|

    stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})
  end

  context "Format weighting A/B test" do
    it "should set the correct A variant tags" do
      with_variant FormatWeighting: "A" do
        get :index, params: { q: "cheese" }
      end
    end

    it "should set the correct B variant tags" do
      with_variant FormatWeighting: "B" do
        get :index, params: { q: "cheese" }
      end
    end
  end
end
