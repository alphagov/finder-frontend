require "spec_helper"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/rummager"

describe FindersController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::Rummager
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
    )

    finder["details"]["default_documents_per_page"] = 10
    finder["details"]["sort"] = nil
    finder
  end

  before do
    Rails.cache.clear
    content_store_has_item("/", "links" => { "level_one_taxons" => [] })
  end
  after { Rails.cache.clear }

  describe "GET show" do
    describe "a finder content item exists" do
      before do
        content_store_has_item(
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
              suggest: "spelling",
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
        expect(response.content_type).to eq("application/atom+xml")
        expect(response).to render_template("finders/show")
        expect(response.headers["Cache-Control"]).to eq("max-age=300, public")
      end

      it "can respond with JSON" do
        get :show, params: { slug: "lunch-finder", format: "json" }

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
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

        content_store_has_item(
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
              suggest: "spelling",
            },
          )
          .to_return(status: 200, body: rummager_response, headers: {})

        get :show, params: { format: :atom, slug: "lunch-finder" }
        expect(stub).to have_been_requested
        expect(response.status).to eq(200)
      end
    end

    describe "finder item doesn't exist" do
      before do
        content_store_does_not_have_item("/does-not-exist")
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
        expect(response.content_type).to eq("application/json")
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
        content_store_has_item("/search/all", all_content_finder)
        content_store_has_item("/lunch-finder", lunch_finder)

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
              suggest: "spelling",
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

  describe "popularity AB test variant" do
    before do
      content_store_has_item("/search/all", all_content_finder)
    end

    it "should request the B popularity variant from search api" do
      request = search_api_request(query: { ab_tests: "popularity:B" })

      with_variant FinderPopularityABTest: "B" do
        get :show, params: { slug: "search/all" }
        expect(request).to have_been_made.once
      end
    end

    it "should not specify a popularity variant from search api by default" do
      request = search_api_request
      with_variant FinderPopularityABTest: "A" do
        get :show, params: { slug: "search/all" }
        expect(request).to have_been_made.once
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
      content_store_has_item(breakfast_finder["base_path"], breakfast_finder)
      rummager_response = %|{
        "results": [],
        "total": 0,
        "start": 0,
        "facets": {},
        "suggested_queries": ["cereal"]
      }|
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})
    end

    it "Gives the spelling suggestion and links to it" do
      get :show, params: { slug: path_for(breakfast_finder), format: "json" }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")

      expect(response.body).to include("cereal")
      expect(response.body).to include("/breakfast-finder?keywords=cereal")
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
          suggest: "spelling",
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
