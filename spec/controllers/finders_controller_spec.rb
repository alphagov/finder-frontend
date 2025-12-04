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
    finder = example_finder
    finder["title"] = "Lunch Finder"
    finder["base_path"] = "/lunch-finder"
    finder["details"]["default_documents_per_page"] = 10
    finder["details"]["sort"] = nil
    finder
  end

  let(:all_content_finder) do
    finder = example_finder
    finder["base_path"] = "/search/all"
    finder["content_id"] = "dd395436-9b40-41f3-8157-740a453ac972"
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
    render_views
    describe "a finder content item exists" do
      before do
        stub_content_store_has_item(
          "/lunch-finder",
          lunch_finder,
          { max_age: 900, public: true },
        )

        search_api_request
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
        expect(response.headers["Cache-Control"]).to eq("max-age=900, public")
      end

      context "When private cache is set" do
        before do
          stub_content_store_has_item(
            "/lunch-finder",
            lunch_finder,
            { max_age: 900, private: true },
          )
        end

        it "can respond with an atom feed with private cache set" do
          get :show, params: { slug: "lunch-finder", format: "atom" }
          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/atom+xml")
          expect(response).to render_template("finders/show")
          expect(response.headers["Cache-Control"]).to eq("max-age=900, private")
        end
      end

      it "can respond with JSON" do
        get :show, params: { slug: "lunch-finder", format: "json" }

        expect(response.status).to eq(200)
        expect(response.media_type).to eq("application/json")
      end

      context "when it receives facet option query params" do
        let(:lunch_finder) do
          finder = example_finder
          finder["title"] = "Lunch Finder"
          finder["base_path"] = "/lunch-finder"
          finder["details"]["default_documents_per_page"] = 10
          finder["details"]["facets"] = [
            {
              "allowed_values": [
                {
                  "label": "Allowed value 1",
                  "value": "allowed-value-1",
                },
                {
                  "label": "Allowed value 2",
                  "value": "allowed-value-2",
                },
              ],
              "filterable": true,
              "key": "some_facet_key",
              "name": "Some facet",
              "type": "text",
            },
          ]
          finder["details"]["sort"] = nil
          finder
        end

        it "initializes a filterable facet with the param field value" do
          stub_content_store_has_item(lunch_finder["base_path"], lunch_finder)

          rummager_response = %({
          "results": [],
          "total": 0,
          "start": 0,
          "facets": [],
          "suggested_queries": []
        })

          stub_request(:get, "#{Plek.find('search-api')}/search.json")
            .with(
              query: {
                count: 10,
                fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,some_facet_key",
                filter_document_type: "mosw_report",
                filter_some_facet_key: %w[allowed-value-1],
                order: "-public_timestamp",
                start: 0,
                suggest: "spelling_with_highlighting",
              },
            )
            .to_return(status: 200, body: rummager_response, headers: {})

          expect(OptionSelectFacet).to receive(:new).with(
            {
              "allowed_values" => [
                {
                  "label" => "Allowed value 1",
                  "value" => "allowed-value-1",
                },
                {
                  "label" => "Allowed value 2",
                  "value" => "allowed-value-2",
                },
              ],
              "filterable" => true,
              "key" => "some_facet_key",
              "name" => "Some facet",
              "type" => "text",
            },
            "allowed-value-1",
          ).and_call_original

          get :show, params: { slug: "lunch-finder", "some_facet_key": "allowed-value-1" }

          expect(response.status).to eq(200)
          expect(response).to render_template("finders/show")
        end
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

        rummager_response = %({
          "results": [],
          "total": 0,
          "start": 0,
          "facets": {},
          "suggested_queries": []
        })

        stub = stub_request(:get, "#{Plek.find('search-api')}/search.json")
          .with(
            query: {
              count: 10,
              fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,walk_type,place_of_origin,date_of_introduction,creator",
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

    describe "a finder doesn't render a malicious search input" do
      it "renders the users malicious input escaped" do
        stub_content_store_has_item("/lunch-finder", lunch_finder)

        stub_request(:get, /\A#{Plek.find('search-api')}\/search.json/)
          .to_return(status: 200, body: rummager_response, headers: {})

        get :show, params: { slug: "lunch-finder", keywords: "<script>alert(0)</script>" }
        expect(response.body).to include("&lt;script&gt;alert(0)&lt;/script&gt;")
        expect(response.body).not_to include("<script>alert(0)</script>")
      end
    end

    describe "a finder requires valid input" do
      it "renders a BadRequest when the keywords parameter is an array" do
        stub_content_store_has_item("/lunch-finder", lunch_finder)

        get :show, params: { slug: "lunch-finder", keywords: ["an", "array", "is invalid"] }
        expect(response.status).to eq(400)
      end

      it "renders a BadRequest when the q parameter is an array" do
        stub_content_store_has_item("/lunch-finder", lunch_finder)

        get :show, params: { slug: "lunch-finder", q: ["an", "array", "is invalid"] }
        expect(response.status).to eq(400)
      end

      it "renders a BadRequest when the q parameter is a hash" do
        stub_content_store_has_item("/lunch-finder", lunch_finder)

        get :show, params: { slug: "lunch-finder", q: { "invalid" => "hash" } }
        expect(response.status).to eq(400)
      end
    end

    describe "finder item doesn't exist" do
      before do
        stub_content_store_does_not_have_item("/does-not-exist")
      end

      it "returns a 404, rather than 5xx" do
        get :show, params: { slug: "does-not-exist" }
        expect(response.status).to eq(404)
        expect(response.body).to include("404 error not found")
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

      it "returns a 404 for HTML requests" do
        get :show, params: { slug: "unpublished-finder" }

        expect(response.status).to eq(404)
        expect(response.body).to include("Not found")
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

    describe "the finder is the all content finder" do
      before do
        search_api_request(search_api_app: "search-api-v2", discovery_engine_attribution_token: "123ABC", query: { q: "hello", order: nil })
        stub_content_store_has_item(
          "/search/all-temp",
          all_content_finder,
        )
      end

      it "correctly renders the new template" do
        get :show, params: { slug: "search/all-temp", keywords: "hello" }
        expect(response.status).to eq(200)
        expect(response).to render_template("finders/show_all_content_finder")
      end
    end

    describe "all content finder SearchFreshnessBoost AB test" do
      before do
        search_api_request(
          search_api_app: "search-api-v2",
          discovery_engine_attribution_token: "123ABC",
          query: { q: "hello", order: nil, serving_config: expected_serving_config },
        )
        stub_content_store_has_item(
          "/search/all-temp",
          all_content_finder,
        )
      end

      context "when the variant is A" do
        let(:expected_serving_config) { nil }

        it "uses the expected serving config" do
          with_variant(SearchFreshnessBoost: "A") do
            get :show, params: { slug: "search/all-temp", keywords: "hello" }
            expect(response.status).to eq(200)
          end
        end
      end

      context "when the variant is B" do
        let(:expected_serving_config) { "variant_search" }

        it "uses the expected serving config" do
          with_variant(SearchFreshnessBoost: "B") do
            get :show, params: { slug: "search/all-temp", keywords: "hello" }
            expect(response.status).to eq(200)
          end
        end
      end

      context "when the variant is Z" do
        let(:expected_serving_config) { nil }

        it "uses the expected serving config" do
          with_variant(SearchFreshnessBoost: "Z") do
            get :show, params: { slug: "search/all-temp", keywords: "hello" }
            expect(response.status).to eq(200)
          end
        end
      end
    end
  end

  describe "Spelling suggestions" do
    let(:breakfast_finder) do
      finder = example_finder
      finder["title"] = "Breakfast Finder"
      finder["base_path"] = "/breakfast-finder"
      finder["content_id"] = "42ce66de-04f3-4192-bf31-8394538e0734"
      finder["details"]["default_documents_per_page"] = 10
      finder["details"]["sort"] = nil
      finder
    end

    before do
      stub_content_store_has_item(breakfast_finder["base_path"], breakfast_finder)
      rummager_response = %({
        "results": [],
        "total": 0,
        "start": 0,
        "facets": {},
        "suggested_queries": [{ "text": "cereal", "highlighted": "<mark>cereal</mark>" }]
      })
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
      stub_content_store_has_item("/search/all-temp", all_content_finder)
    end

    rummager_response = %({
      "results": [],
      "total": 0,
      "start": 0,
      "facets": {},
      "suggested_queries":[]
    })

    it "detects bad 'from' dates" do
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})

      get :show, params: { slug: "search/all-temp", format: "json", public_timestamp: { from: "99-99-99", to: "01-01-01" } }
      json_response = JSON.parse(response.body)

      expect(json_response["errors"]["public_timestamp"]["from"]).to be true
      expect(json_response["errors"]["public_timestamp"]["to"]).to be false
    end

    it "detects bad 'to' dates" do
      stub_request(:get, /search.json/).to_return(status: 200, body: rummager_response, headers: {})

      get :show, params: { slug: "search/all-temp", format: "json", public_timestamp: { from: "01-01-01", to: "99-99-99" } }

      json_response = JSON.parse(response.body)
      expect(json_response["errors"]["public_timestamp"]["from"]).to be false
      expect(json_response["errors"]["public_timestamp"]["to"]).to be true
    end
  end

  describe "with legacy query parameters for announcements" do
    before do
      search_api_request

      news_finder = example_finder
      news_finder["base_path"] = "/search/news-and-communications"
      news_finder["content_id"] = "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
      news_finder["details"]["default_documents_per_page"] = 10
      news_finder["details"]["sort"] = nil

      stub_content_store_has_item("/search/news-and-communications", news_finder)

      @default_params = { slug: "search/news-and-communications" }
    end

    describe "when there are legacy parameters present" do
      it "strips out all from taxons parameter" do
        expect(get(:show, params: @default_params.merge(taxons: %w[all]))).to redirect_to("/search/news-and-communications")
      end

      it "strips out all from subtaxons parameter" do
        expect(get(:show, params: @default_params.merge(subtaxons: %w[all]))).to redirect_to("/search/news-and-communications")
      end

      it "strips out all from departments parameter" do
        expect(get(:show, params: @default_params.merge(departments: %w[all]))).to redirect_to("/search/news-and-communications")
      end

      it "replaces departments with organisations parameter" do
        expect(get(:show, params: @default_params.merge(departments: %w[cabinet-office]))).to redirect_to("/search/news-and-communications?organisations%5B%5D=cabinet-office")
      end
    end

    it "redirects a request using both a non-default finder and has legacy parameters" do
      expected_query_string = {
        level_one_taxon: "education",
        level_two_taxon: "schools",
        organisations: %w[cabinet-office hm-revenue-and-customs],
      }.to_query

      expect(get(:show, params: @default_params.merge(
        departments: %w[cabinet-office hm-revenue-and-customs],
        taxons: %w[education],
        subtaxons: %w[schools],
      ))).to redirect_to("/search/news-and-communications?#{expected_query_string}")
    end
  end

  describe "with legacy query parameters for publications" do
    before do
      search_api_request
      stub_content_store_has_item("/search/all", all_content_finder)

      @default_params = { slug: "search/all" }
    end

    describe "when a non-default finder is needed" do
      it "redirects to official-documents finder for command_and_act_papers" do
        expect(get(:show, params: @default_params.merge(official_document_status: "command_and_act_papers"))).to redirect_to("/official-documents")
      end

      it "redirects to official-documents finder with parameters for command_papers" do
        expect(get(:show, params: @default_params.merge(official_document_status: "command_papers"))).to redirect_to("/official-documents?content_store_document_type=command_papers")
      end

      it "redirects to official-documents finder with parameters for act_papers" do
        expect(get(:show, params: @default_params.merge(official_document_status: "act_papers"))).to redirect_to("/official-documents?content_store_document_type=act_papers")
      end

      it "redirects to policy-papers-and-consultations finder with parameters for consultations" do
        expect(get(:show, params: @default_params.merge(publication_type: "consultations"))).to redirect_to("/search/policy-papers-and-consultations?content_store_document_type%5B%5D=open_consultations&content_store_document_type%5B%5D=closed_consultations")
      end

      it "redirects to policy-papers-and-consultations finder with parameters for closed-consultations" do
        expect(get(:show, params: @default_params.merge(publication_type: "closed-consultations"))).to redirect_to("/search/policy-papers-and-consultations?content_store_document_type=closed_consultations")
      end

      it "redirects to policy-papers-and-consultations finder with parameters for open-consultations" do
        expect(get(:show, params: @default_params.merge(publication_type: "open-consultations"))).to redirect_to("/search/policy-papers-and-consultations?content_store_document_type=open_consultations")
      end

      it "redirects to transparency-and-freedom-of-information-releases finder with parameters for foi-releases" do
        expect(get(:show, params: @default_params.merge(publication_type: "foi-releases"))).to redirect_to("/search/transparency-and-freedom-of-information-releases?content_store_document_type=foi_release")
      end

      it "redirects to transparency-and-freedom-of-information-releases finder with parameters for transparency-data" do
        expect(get(:show, params: @default_params.merge(publication_type: "transparency-data"))).to redirect_to("/search/transparency-and-freedom-of-information-releases?content_store_document_type=transparency")
      end

      it "redirects to transparency-and-freedom-of-information-releases finder with parameters for corporate-reports" do
        expect(get(:show, params: @default_params.merge(publication_type: "corporate-reports"))).to redirect_to("/search/transparency-and-freedom-of-information-releases?content_store_document_type=corporate_report")
      end

      it "redirects to guidance-and-regulation finder for guidance" do
        expect(get(:show, params: @default_params.merge(publication_type: "guidance"))).to redirect_to("/search/guidance-and-regulation")
      end

      it "redirects to guidance-and-regulation finder for regulations" do
        expect(get(:show, params: @default_params.merge(publication_type: "regulations"))).to redirect_to("/search/guidance-and-regulation")
      end

      it "redirects to policy-papers-and-consultations finder with parameters for corporate-reports" do
        expect(get(:show, params: @default_params.merge(publication_type: "policy-papers"))).to redirect_to("/search/policy-papers-and-consultations?content_store_document_type=policy_papers")
      end

      it "redirects to services finder for forms" do
        expect(get(:show, params: @default_params.merge(publication_type: "forms"))).to redirect_to("/search/services")
      end

      it "redirects to research-and-statistics finder with parameters for corporate-reports" do
        expect(get(:show, params: @default_params.merge(publication_type: "research-and-analysis"))).to redirect_to("/search/research-and-statistics?content_store_document_type=research")
      end

      it "redirects to research-and-statistics finder for statistics" do
        expect(get(:show, params: @default_params.merge(publication_type: "statistics"))).to redirect_to("/search/research-and-statistics")
      end

      it "returns a 406 if there are unfiltered parameters" do
        get(:show, params: @default_params.merge(publication_type: "foi-releases", organisations: { foo: "bar" }))
        expect(response.status).to eq(406)
      end
    end

    describe "when there are legacy parameters present" do
      it "strips out all from taxons parameter" do
        expect(get(:show, params: @default_params.merge(taxons: %w[all]))).to redirect_to("/search/all")
      end

      it "strips out all from subtaxons parameter" do
        expect(get(:show, params: @default_params.merge(subtaxons: %w[all]))).to redirect_to("/search/all")
      end

      it "strips out all from departments parameter" do
        expect(get(:show, params: @default_params.merge(departments: %w[all]))).to redirect_to("/search/all")
      end

      it "replaces departments with organisations parameter" do
        expect(get(:show, params: @default_params.merge(departments: %w[cabinet-office]))).to redirect_to("/search/all?organisations%5B%5D=cabinet-office")
      end
    end

    it "redirects a request using both a non-default finder and has legacy parameters" do
      expected_query_string = {
        content_store_document_type: %w[open_consultations closed_consultations],
        level_one_taxon: "education",
        level_two_taxon: "schools",
        organisations: %w[cabinet-office hm-revenue-and-customs],
      }.to_query

      expect(get(:show, params: @default_params.merge(
        publication_type: "consultations",
        departments: %w[cabinet-office hm-revenue-and-customs],
        taxons: %w[education],
        subtaxons: %w[schools],
      ))).to redirect_to("/search/policy-papers-and-consultations?#{expected_query_string}")
    end
  end

  def search_api_request(query: {}, search_api_app: "search-api", discovery_engine_attribution_token: nil)
    stub_request(:get, "#{Plek.find(search_api_app)}/search.json")
      .with(
        query: {
          count: 10,
          fields: "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,walk_type,place_of_origin,date_of_introduction,creator",
          filter_document_type: "mosw_report",
          order: "-public_timestamp",
          start: 0,
          suggest: "spelling_with_highlighting",
        }.merge(query).compact,
      )
      .to_return(
        status: 200,
        body: search_response(discovery_engine_attribution_token:),
        headers: {},
      )
  end

  def search_response(discovery_engine_attribution_token: nil)
    return rummager_response if discovery_engine_attribution_token.blank?

    JSON.generate(
      JSON.parse(rummager_response)
          .merge!("discovery_engine_attribution_token" => discovery_engine_attribution_token),
    )
  end

  def rummager_response
    %({
      "results": [],
      "total": 11,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def path_for(content_item, locale = nil)
    base_path = content_item["base_path"].sub(/^\//, "")
    base_path.gsub!(/\.#{locale}$/, "") if locale
    base_path
  end
end
