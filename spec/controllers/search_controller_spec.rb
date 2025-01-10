require "spec_helper"
require "gds_api/test_helpers/content_store"

describe SearchController, type: :controller do
  include GdsApi::TestHelpers::ContentStore

  before do
    stub_content_store_has_item("/search")
  end

  describe "GET index" do
    render_views

    it "renders the search page" do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template("search/no_search_term")
    end

    context "when given search parameters" do
      it "redirects to the all content finder" do
        get :index, params: { q: "my search" }

        destination = finder_path("search/all",
                                  params: { keywords: "my search", order: "relevance" })
        expect(response).to redirect_to(destination)
      end
    end

    context "when JSON is requested" do
      it "redirects to the all content finder" do
        get :index, format: :json

        destination = finder_path("search/all",
                                  params: { order: "relevance", format: "json" })
        expect(response).to redirect_to(destination)
      end
    end
  end
end
