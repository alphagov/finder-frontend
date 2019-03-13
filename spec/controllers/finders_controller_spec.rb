require 'spec_helper'
require 'gds_api/test_helpers/content_store'

describe FindersController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include GovukContentSchemaExamples
  render_views

  describe "GET show" do
    let(:lunch_finder) do
      finder = govuk_content_schema_example('finder').to_hash.merge(
        'title' => 'Lunch Finder',
        'base_path' => '/lunch-finder',
      )

      finder["details"]["default_documents_per_page"] = 10
      finder["details"]["sort"] = nil
      finder
    end

    let(:all_content_finder) do
      finder = govuk_content_schema_example('finder').to_hash.merge(
        'base_path' => '/all-content',
      )

      finder["details"]["default_documents_per_page"] = 10
      finder["details"]["sort"] = nil
      finder
    end

    describe "a finder content item exists" do
      before do
        content_store_has_item(
          '/lunch-finder',
          lunch_finder
        )

        rummager_response = %|{
          "results": [
            {
              "results": [],
              "total": 11,
              "start": 0,
              "facets": {},
              "suggested_queries": []
            }
          ]
        }|

        url = "#{Plek.current.find('search')}/batch_search.json?search[][0][count]=10&search[][0][fields]=title,link,description,public_timestamp,popularity,content_purpose_supergroup,walk_type,place_of_origin,date_of_introduction,creator&search[][0][filter_document_type]=mosw_report&search[][0][order]=-public_timestamp&search[][0][start]=0"

        stub_request(:get, url)
          .to_return(status: 200, body: rummager_response, headers: {})
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
        expect(response.headers['Cache-Control']).to eq("max-age=300, public")
      end

      it "can respond with JSON" do
        get :show, params: { slug: "lunch-finder", format: "json" }

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
      end

      describe "canonical links" do
        let(:canonical_finder) do
          finder = govuk_content_schema_example('finder').to_hash.merge(
            'title' => 'Canonical Finder',
            'base_path' => '/canonical-finder',
          )

          finder['details']['canonical_link'] = true
          finder["details"]["default_documents_per_page"] = 10
          finder["details"]["sort"] = nil
          finder
        end

        before do
          content_store_has_item(
            '/canonical_finder',
            canonical_finder
          )
        end

        it "are not shown if the finder does not have a canonical_link field" do
          get :show, params: { slug: "lunch-finder" }
          expect(response.body).not_to include('<link rel="canonical"')
        end

        it "are shown if the finder has a canonical_link field" do
          get :show, params: { slug: "canonical_finder" }

          expect(response.body).to include("<link rel=\"canonical\" href=\"#{ENV['GOVUK_WEBSITE_ROOT']}/canonical-finder\">")
        end
      end

      it "returns a 406 if an invalid format is requested" do
        request.headers["Accept"] = "text/plain"
        get :show, params: { slug: "lunch-finder" }
        expect(response.status).to eq(406)
      end
    end

    describe "a finder content item with a default order exists" do
      before do
        sort_options = [{ 'name' => 'Closing date', 'key' => '-closing_date', 'default' => true, }]

        content_store_has_item(
          '/lunch-finder',
          lunch_finder.merge('details' => lunch_finder['details'].merge('sort' => sort_options))
        )

        rummager_response = %|{
          "results": [
            {
              "results": [],
              "total": 0,
              "start": 0,
              "facets": {},
              "suggested_queries": []
            }
          ]
        }|

        stub_request(:get, "#{Plek.current.find('search')}/batch_search.json?search[][0][count]=10&search[][0][fields]=title,link,description,public_timestamp,popularity,content_purpose_supergroup,walk_type,place_of_origin,date_of_introduction,creator&search[][0][filter_document_type]=mosw_report&search[][0][order]=-closing_date&search[][0][start]=0").
          to_return(status: 200, body: rummager_response, headers: {})
      end

      it "returns a 404 when requesting an atom feed, rather than a 500" do
        get :show, params: { format: :atom, slug: 'lunch-finder' }
        expect(response.status).to eq(404)
      end
    end

    describe "finder item doesn't exist" do
      before do
        content_store_does_not_have_item('/does-not-exist')
      end

      it 'returns a 404, rather than 5xx' do
        get :show, params: { slug: 'does-not-exist' }
        expect(response.status).to eq(404)
      end

      it 'returns a 404, rather than 5xx for the atom feed' do
        get :show, params: { slug: "does-not-exist", format: "atom" }

        expect(response.status).to eq(404)
      end
    end

    describe "finder item has been unpublished" do
      before do
        stub_request(:get, "#{Plek.find('content-store')}/content/unpublished-finder").to_return(
          status: 200,
          body: {
            document_type: 'redirect',
            schema_name: 'redirect',
            redirects: [
              { path: '/unpublished-finder', type: 'exact', destination: '/replacement' }
            ]
          }.to_json,
          headers: {}
        )
      end

      it 'returns a message indicating the atom feed has ended' do
        get :show, params: { slug: "unpublished-finder", format: "atom" }

        expect(response.status).to eq(200)
        expect(response.body).to include("This feed no longer exists")
      end

      it 'returns a 404 for json responses' do
        get :show, params: { slug: "unpublished-finder", format: "json" }

        expect(response.status).to eq(404)
        expect(response.content_type).to eq("application/json")
      end

      context "and it was a policy finder page" do
        before do
          stub_request(:get, "#{Plek.find('content-store')}/content/government/policies/cats").to_return(
            status: 200,
            body: {
              document_type: 'redirect',
              schema_name: 'redirect',
              redirects: [
                { path: '/government/policies/cats', type: 'exact', destination: '/cats' }
              ]
            }.to_json,
            headers: {}
          )
        end

        it 'returns a policy specific message indicating the atom feed has ended' do
          get :show, params: { slug: "government/policies/cats", format: "atom" }

          expect(response.status).to eq(200)
          expect(response.body).to include("Policy pages and their atom feeds have been retired")
        end
      end
    end

    describe "Show/Hiding site search form" do
      before do
        content_store_has_item('/all-content', all_content_finder)
        content_store_has_item('/lunch-finder', lunch_finder)

        rummager_response = %|{
            "results": [
              {
                "results": [],
                "total": 0,
                "start": 0,
                "facets": {},
                "suggested_queries": []
              }
            ]
          }|

        stub_request(:get, "#{Plek.current.find('search')}/batch_search.json?search%5B%5D%5B0%5D%5Bcount%5D=10&search%5B%5D%5B0%5D%5Bfields%5D=title,link,description,public_timestamp,popularity,content_purpose_supergroup,walk_type,place_of_origin,date_of_introduction,creator&search%5B%5D%5B0%5D%5Bfilter_document_type%5D=mosw_report&search%5B%5D%5B0%5D%5Border%5D=-public_timestamp&search%5B%5D%5B0%5D%5Bstart%5D=0").
            to_return(status: 200, body: rummager_response, headers: {})
      end

      it 'all content finder tells Slimmer to hide the form' do
        get :show, params: { slug: 'all-content' }
        expect(response.headers["X-Slimmer-Remove-Search"]).to eq("true")
      end

      it 'any other finder does not tell Slimmer to hide the form' do
        get :show, params: { slug: 'lunch-finder' }
        expect(response.headers).not_to include("X-Slimmer-Remove-Search")
      end
    end
  end
end
