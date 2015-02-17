require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore
include FixturesHelper

describe FindersController do
  describe "GET show" do

    describe "a finder content item exists" do
      before do
        content_store_has_item('/lunch-finder',
          {
            base_path: '/lunch-finder',
            title: 'Lunch Finder',
            details: {
              facets: [],
            },
            links: {
              organisations: [],
            },
          }
        )

        rummager_response = %|{
            "results": [],
            "total": 0,
            "start": 0,
            "facets": {},
            "suggested_queries": []
          }|

        stub_request(:get, "#{Plek.current.find('search')}/unified_search.json?count=1000&fields=title,link,description,last_update&order=-last_update").to_return(:status => 200, :body => rummager_response, :headers => {})
      end

      it "correctly renders a finder page" do
        get :show, slug: 'lunch-finder'
        expect(response.status).to eq(200)
        expect(response).to render_template("finders/show")
      end

      it "can respond with an atom feed" do
        get :show, slug: "lunch-finder", format: "atom"
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/atom+xml")
        expect(response).to render_template("finders/show")
      end
    end

    describe "finder item doesn't exist" do
      it 'returns a 404, rather than 5xx' do
        content_store_does_not_have_item('/does-not-exist')

        get :show, slug: 'does-not-exist'
        expect(response.status).to eq(404)
      end
    end
  end
end
