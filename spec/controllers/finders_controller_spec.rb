require "spec_helper"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/search"

describe FindersController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::Search
  include GovukAbTesting::RspecHelpers

  render_views

  let(:lunch_finder) do
    finder = govuk_content_schema_example("finder").to_hash.merge(
      "title" => "Lunch Finder",
      "base_path" => "/lunch-finder",
    )

    finder["details"]["default_documents_per_page"] = 10
    finder["details"]["sort"] = nil
    finder
  end

  let(:all_content_finder) do
    finder = govuk_content_schema_example("finder").to_hash.merge(
      "base_path" => "/search/all",
      "content_id" => "dd395436-9b40-41f3-8157-740a453ac972",
    )

    finder["details"]["default_documents_per_page"] = 10
    finder["details"]["sort"] = nil
    finder
  end

  before do
    Rails.cache.clear
    stub_content_store_has_item("/", "links" => { "level_one_taxons" => [] })
  end
  after { Rails.cache.clear }

  describe "GET show" do
    describe "a finder content item exists" do
      before do
        stub_content_store_has_item(
          "/lunch-finder",
          lunch_finder,
        )

        url = "#{Plek.current.find('search')}/search.json"

        stub_request(:get, url)
          .with(
            query: {
              count: 10,
              fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,walk_type,place_of_origin,date_of_introduction,creator",
              filter_document_type: "mosw_report",
              order: "-public_timestamp",
              start: 0,
              suggest: "spelling_with_highlighting",
            },
          )
          .to_return(status: 200, body: rummager_response, headers: {})
      end

      it "correctly renders a finder page" do
        get :show, params: { slug: "lunch-finder" }
        expect(response.status).to eq(200)
        expect(response).to render_template("finders/show")
      end

      it "can respond with an atom feed" do
        get :show, params: { slug: "lunch-finder", format: "atom" }
        expect(response.status).to eq(200)
        expect(response.media_type).to eq("application/atom+xml")
        expect(response).to render_template("finders/show")
        expect(response.headers["Cache-Control"]).to eq("max-age=300, public")
      end

      it "can respond with JSON" do
        get :show, params: { slug: "lunch-finder", format: "json" }

        expect(response.status).to eq(200)
        expect(response.media_type).to eq("application/json")
      end

      it "returns a 406 if an invalid format is requested" do
        request.headers["Accept"] = "text/plain"
        get :show, params: { slug: "lunch-finder" }
        expect(response.status).to eq(406)
      end
    end

    describe "a finder content item with a default order exists" do
      it "sorts the finder results by public timestamp" do
        sort_options = [{ "name" => "Closing date", "key" => "-closing_date", "default" => true }]

        stub_content_store_has_item(
          "/lunch-finder",
          lunch_finder.merge("details" => lunch_finder["details"].merge("sort" => sort_options)),
        )

        rummager_response = %|{
          "results": [],
          "total": 0,
          "start": 0,
          "facets": {},
          "suggested_queries": []
        }|

        stub = stub_request(:get, "#{Plek.current.find('search')}/search.json")
          .with(
            query: {
              count: 10,
              fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,walk_type,place_of_origin,date_of_introduction,creator",
              filter_document_type: "mosw_report",
              order: "-public_timestamp",
              start: 0,
              suggest: "spelling_with_highlighting",
            },
          )
          .to_return(status: 200, body: rummager_response, headers: {})

        get :show, params: { format: :atom, slug: "lunch-finder" }
        expect(stub).to have_been_requested
        expect(response.status).to eq(200)
      end
    end

    describe "parts in results A/B test" do
      before do
        stub_content_store_has_item(
          "/lunch-finder",
          lunch_finder,
        )

        url = "#{Plek.current.find('search')}/search.json"

        stub_request(:get, url)
          .with(
            query: {
              count: 10,
              fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,walk_type,place_of_origin,date_of_introduction,creator,parts",
              filter_document_type: "mosw_report",
              order: "-public_timestamp",
              start: 0,
              suggest: "spelling_with_highlighting",
            },
          )
          .to_return(status: 200, body: rummager_response, headers: {})
      end

      it "requests parts from search-api" do
        with_variant ShowPartsInResultsABTest: "showparts" do
          get :show, params: { slug: "lunch-finder" }
          expect(response.status).to eq(200)
          expect(response).to render_template("finders/show")
        end
      end
    end

    describe "finder item doesn't exist" do
      before do
        stub_content_store_does_not_have_item("/does-not-exist")
      end

      it "returns a 404, rather than 5xx" do
        get :show, params: { slug: "does-not-exist" }
        expect(response.status).to eq(404)
      end

      it "returns a 404, rather than 5xx for the atom feed" do
        get :show, params: { slug: "does-not-exist", format: "atom" }

        expect(response.status).to eq(404)
      end
    end

    describe "finder item returns forbidden response when user not authorised" do
      let(:forbidden_slug) { "/#{SecureRandom.hex}" }

      before do
        url = "#{Plek.find('content-store')}/content/#{forbidden_slug}"
        stub_request(:get, url).to_return(status: 403, headers: {})
      end

      it "returns 403" do
        get :show, params: { slug: forbidden_slug }

        expect(response.status).to eq 403
      end
    end

    describe "finder item has been unpublished" do
      before do
        stub_request(:get, "#{Plek.find('content-store')}/content/unpublished-finder").to_return(
          status: 200,
          body: {
            document_type: "redirect",
            schema_name: "redirect",
            redirects: [
              { path: "/unpublished-finder", type: "exact", destination: "/replacement" },
            ],
          }.to_json,
          headers: {},
        )
      end

      it "returns a message indicating the atom feed has ended" do
        get :show, params: { slug: "unpublished-finder", format: "atom" }

        expect(response.status).to eq(200)
        expect(response.body).to include("This feed no longer exists")
      end

      it "returns a 404 for json responses" do
        get :show, params: { slug: "unpublished-finder", format: "json" }

        expect(response.status).to eq(404)
        expect(response.media_type).to eq("application/json")
      end

      context "and it was a policy finder page" do
        before do
          stub_request(:get, "#{Plek.find('content-store')}/content/government/policies/cats").to_return(
            status: 200,
            body: {
              document_type: "redirect",
              schema_name: "redirect",
              redirects: [
                { path: "/government/policies/cats", type: "exact", destination: "/cats" },
              ],
            }.to_json,
            headers: {},
          )
        end

        it "returns a policy specific message indicating the atom feed has ended" do
          get :show, params: { slug: "government/policies/cats", format: "atom" }

          expect(response.status).to eq(200)
          expect(response.body).to include("Policy pages and their atom feeds have been retired")
        end
      end
    end

    describe "Show/Hiding site search form" do
      before do
        stub_content_store_has_item("/search/all", all_content_finder)
        stub_content_store_has_item("/lunch-finder", lunch_finder)

        rummager_response = %|{
          "results": [],
          "total": 0,
          "start": 0,
          "facets": {},
          "suggested_queries": []
        }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json")
          .with(
            query: {
              count: 10,
              fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,walk_type,place_of_origin,date_of_introduction,creator",
              filter_document_type: "mosw_report",
              order: "-public_timestamp",
              start: 0,
              suggest: "spelling_with_highlighting",
            },
          )
          .to_return(status: 200, body: rummager_response, headers: {})
      end

      it "all content finder tells Slimmer to hide the form" do
        get :show, params: { slug: "search/all" }
        expect(response.headers["X-Slimmer-Remove-Search"]).to eq("true")
      end

      it "any other finder does not tell Slimmer to hide the form" do
        get :show, params: { slug: "lunch-finder" }
        expect(response.headers).not_to include("X-Slimmer-Remove-Search")
      end
    end
  end

  describe "Spelling suggestions" do
    let(:breakfast_finder) do
      finder = govuk_content_schema_example("finder").to_hash.merge(
        "title" => "Breakfast Finder",
        "base_path" => "/breakfast-finder",
        "content_id" => "42ce66de-04f3-4192-bf31-8394538e0734",
      )

      finder["details"]["default_documents_per_page"] = 10
      finder["details"]["sort"] = nil
      finder
    end

    before do
      stub_content_store_has_item(breakfast_finder["base_path"], breakfast_finder)
      rummager_response = %|{
        "results": [],
        "total": 0,
        "start": 0,
        "facets": {},
        "suggested_queries": [{ "text": "cereal", "highlighted": "<mark>cereal</mark>" }]
      }|
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})
    end

    it "Gives the spelling suggestion and links to it" do
      get :show, params: { slug: path_for(breakfast_finder), format: "json" }
      expect(response.status).to eq(200)
      expect(response.media_type).to eq("application/json")

      expect(response.body).to include("cereal")
      expect(response.body).to include("/breakfast-finder?keywords=cereal")
    end
  end

  describe "Errors on date filters" do
    before do
      stub_content_store_has_item("/search/all", all_content_finder)
    end

    rummager_response = %|{
      "results": [],
      "total": 0,
      "start": 0,
      "facets": {},
      "suggested_queries":[]
    }|

    it "should detect bad 'from' dates" do
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})

      get :show, params: { slug: "search/all", format: "json", public_timestamp: { from: "99-99-99", to: "01-01-01" } }
      json_response = JSON.parse(response.body)

      expect(json_response["errors"]["public_timestamp"]["from"]).to be true
      expect(json_response["errors"]["public_timestamp"]["to"]).to be false
    end

    it "should detect bad 'to' dates" do
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})

      get :show, params: { slug: "search/all", format: "json", public_timestamp: { from: "01-01-01", to: "99-99-99" } }

      json_response = JSON.parse(response.body)
      expect(json_response["errors"]["public_timestamp"]["from"]).to be false
      expect(json_response["errors"]["public_timestamp"]["to"]).to be true
    end
  end

  def search_api_request(query: {})
    stub_request(:get, "#{Plek.current.find('search')}/search.json")
      .with(
        query: {
          count: 10,
          fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,walk_type,place_of_origin,date_of_introduction,creator",
          filter_document_type: "mosw_report",
          order: "-public_timestamp",
          start: 0,
          suggest: "spelling_with_highlighting",
        }.merge(query),
      )
      .to_return(status: 200, body: rummager_response, headers: {})
  end

  def rummager_response
    %|{
      "results": [],
      "total": 11,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def path_for(content_item, locale = nil)
    base_path = content_item["base_path"].sub(/^\//, "")
    base_path.gsub!(/\.#{locale}$/, "") if locale
    base_path
  end
end
