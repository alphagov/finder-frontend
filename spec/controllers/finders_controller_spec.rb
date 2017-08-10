require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore
include FixturesHelper
include GovukAbTesting::RspecHelpers

describe FindersController, type: :controller do
  describe "GET show" do
    describe "a finder content item exists" do
      before do
        content_store_has_item(
          '/lunch-finder',
            base_path: '/lunch-finder',
            title: 'Lunch Finder',
            details: {
              facets: [],
            },
            links: {
              organisations: [],
            },
        )

        rummager_response = %|{
            "results": [],
            "total": 0,
            "start": 0,
            "facets": {},
            "suggested_queries": []
          }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json?count=1000&fields=title,link,description,public_timestamp&order=-public_timestamp&start=0").to_return(status: 200, body: rummager_response, headers: {})
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
            base_path: '/lunch-finder',
            title: 'Lunch Finder',
            details: {
              default_order: "-closing_date",
              facets: [],
            },
            links: {
              organisations: [],
            },
        )

        rummager_response = %|{
            "results": [],
            "total": 0,
            "start": 0,
            "facets": {},
            "suggested_queries": []
          }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json?count=1000&fields=title,link,description,public_timestamp&order=-closing_date&start=0").to_return(status: 200, body: rummager_response, headers: {})
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

    describe "viewing a policies finder with an a/b test" do
      before do
        content_store_has_item(
          '/government/policies',
            base_path: '/government/policies',
            title: 'Policies',
            details: {
              facets: [],
            },
            links: {
              organisations: [],
            },
        )

        content_store_has_item(
          '/government/policies/all',
            base_path: '/government/policies/all',
            title: 'All Policies',
            details: {
              facets: [],
            },
            links: {
              organisations: [],
            },
        )

        content_store_has_item(
          '/government/policies/child-policy',
            base_path: '/government/policies/child-policy',
            title: 'Child Policy',
            details: {
              facets: [],
            },
            links: {
              organisations: [],
            },
        )

        rummager_response = %|{
            "results": [],
            "total": 0,
            "start": 0,
            "facets": {},
            "suggested_queries": []
          }|

        stub_request(:get, "#{Plek.current.find('search')}/search.json?count=1000&fields=title,link,description,public_timestamp&order=-public_timestamp&start=0").to_return(status: 200, body: rummager_response, headers: {})
      end

      it "directs users in group A to the normal policies finder" do
        setup_ab_variant("PolicyFinderTest", "A")

        get :show, params: { slug: 'government/policies' }
        finder_slug = subject.instance_variable_get(:@results).finder.slug

        expect(response.status).to eq(200)
        expect(finder_slug).to eq("/government/policies")
      end

      it "directs users in group B to the all policies finder" do
        setup_ab_variant("PolicyFinderTest", "B")

        get :show, params: { slug: 'government/policies' }
        finder_slug = subject.instance_variable_get(:@results).finder.slug

        expect(response.status).to eq(200)
        expect(finder_slug).to eq("/government/policies/all")
      end

      it "directs all users to a finder that is not part of the A/B test" do
        %w(A B).each do |variant|
          setup_ab_variant("PolicyFinderTest", variant)

          get :show, params: { slug: 'government/policies/child-policy' }
          finder_slug = subject.instance_variable_get(:@results).finder.slug

          expect(response.status).to eq(200)
          expect(finder_slug).to eq("/government/policies/child-policy")
        end
      end
    end
  end
end
