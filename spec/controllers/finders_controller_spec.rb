require 'spec_helper'
require 'gds_api/test_helpers/content_store'

describe FindersController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include GovukContentSchemaExamples
  render_views

  describe "GET show" do
    let(:lunch_finder) {
      govuk_content_schema_example('finder').to_hash.merge(
        'title' => 'Lunch Finder',
        'base_path' => '/lunch-finder'
      )
    }
    describe "a finder content item exists" do
      before do
        content_store_has_item(
          '/lunch-finder',
          lunch_finder
        )

        rummager_response = %|{
          "results": [],
          "total": 0,
          "start": 0,
          "facets": {},
          "suggested_queries": []
        }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json?count=1000&fields=title,link,description,public_timestamp,walk_type,place_of_origin,date_of_introduction,creator&filter_document_type=mosw_report&order=-public_timestamp&start=0").
          to_return(status: 200, body: rummager_response, headers: {})
      end

      it "correctly renders a finder page" do
        get :show, params: { slug: 'lunch-finder' }
        expect(response.status).to eq(200)
        expect(response).to render_template("finders/show")
      end

      it "can respond with an atom feed" do
        get :show, params: { slug: "lunch-finder", format: "atom" }
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/atom+xml")
        expect(response).to render_template("finders/show")
      end

      it "returns a 406 if an invalid format is requested" do
        request.headers["Accept"] = "text/plain"
        get :show, params: { slug: "lunch-finder" }
        expect(response.status).to eq(406)
      end
    end

    describe "a finder content item with a default order exists" do
      before do
        content_store_has_item(
          '/lunch-finder',
          lunch_finder.merge(
            'details' => lunch_finder['details'].merge('default_order' => "-closing_date")
          )
        )

        rummager_response = %|{
          "results": [],
          "total": 0,
          "start": 0,
          "facets": {},
          "suggested_queries": []
        }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json?count=1000&fields=title,link,description,public_timestamp,walk_type,place_of_origin,date_of_introduction,creator&filter_document_type=mosw_report&order=-closing_date&start=0").
          to_return(status: 200, body: rummager_response, headers: {})
      end

      it "returns a 404 when requesting an atom feed, rather than a 500" do
        get :show, params: { format: :atom, slug: 'lunch-finder' }
        expect(response.status).to eq(404)
      end
    end

    describe "finder item doesn't exist" do
      it 'returns a 404, rather than 5xx' do
        content_store_does_not_have_item('/does-not-exist')

        get :show, params: { slug: 'does-not-exist' }
        expect(response.status).to eq(404)
      end
    end
  end
end
