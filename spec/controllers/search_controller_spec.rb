require "spec_helper"
require "gds_api/test_helpers/content_store"

describe SearchController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include GovukAbTesting::RspecHelpers
  render_views

  before do
    content_store_has_item(
      "/search",
      base_path: "/search",
      title: "Search",
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
end
