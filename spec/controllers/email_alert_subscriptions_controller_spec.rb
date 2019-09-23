require "spec_helper"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/email_alert_api"

describe EmailAlertSubscriptionsController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi
  include FixturesHelper
  include GovukContentSchemaExamples
  include TaxonomySpecHelper
  include RegistrySpecHelper

  render_views

  let(:signup_finder) { cma_cases_signup_content_item }
  let(:content_id_one) { "magical-education" }
  let(:content_id_two) { "herbology" }
  let(:top_level_taxon_one_title) { "Magical Education" }
  let(:top_level_taxon_two_title) { "Herbology" }

  before { Rails.cache.clear }
  after { Rails.cache.clear }

  before :each do
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: content_id_one, title: top_level_taxon_one_title),
      FactoryBot.build(:level_one_taxon_hash, content_id: content_id_two, title: top_level_taxon_two_title),
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  describe "GET #new" do
    describe "finder email signup item doesn't exist" do
      it "returns a 404, rather than 5xx" do
        content_store_does_not_have_item("/does-not-exist/email-signup")
        get :new, params: { slug: "does-not-exist" }
        expect(response.status).to eq(404)
      end
    end

    describe "finder email signup item does exist" do
      it "returns a success" do
        content_store_has_item("/does-exist/email-signup", signup_finder)
        get :new, params: { slug: "does-exist" }

        expect(response).to be_successful
      end
    end
  end

  describe 'POST "#create"' do
    before do
      content_store_has_item("/cma-cases", cma_cases_content_item)
      content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
    end

    context "finder has default filters" do
      it "fails if the relevant filters are not provided" do
        post :create, params: { slug: "cma-cases" }
        expect(response).to be_successful
        expect(response).to render_template("new")
      end

      it "redirects to the correct email subscription url" do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "case_type" => { any: %w[ca98-and-civil-cartels] },
            "format" => { any: %w[cma_case] },
          },
          "subscription_url" => "http://www.example.com",
        )

        post :create, params: {
          slug: "cma-cases",
          filter: {
            "case_type" => %w[ca98-and-civil-cartels],
          },
        }
        expect(subject).to redirect_to("http://www.example.com")
      end
    end
  end

  context "with a multi facet signup" do
    describe 'POST "#create"' do
      it "redirects to the correct email subscription url" do
        content_store_has_item("/cma-cases", cma_cases_content_item)
        content_store_has_item("/cma-cases/email-signup", cma_cases_with_multi_facets_signup_content_item)

        email_alert_api_has_subscriber_list(
          "tags" => {
            "case_type" => { any: %w[ca98-and-civil-cartels] },
            "case_state" => { any: %w(open) },
            "format" => { any: %w[cma_case] },
          },
          "subscription_url" => "http://www.example.com",
        )

        post :create, params: {
          slug: "cma-cases",
          filter: {
            "case_type" => %w[ca98-and-civil-cartels],
            "case_state" => %w(open),
          },
        }

        expect(subject).to redirect_to("http://www.example.com")
      end

      it "redirects to the correct email subscription url with subscriber_list_params" do
        content_store_has_item("/news-and-communications", news_and_communications_content_item)
        content_store_has_item("/news-and-communications/email-signup", news_and_communications_signup_content_item)

        email_alert_api_has_subscriber_list(
          "links" => {
            "content_purpose_subgroup" =>
              {
                "any" => %w[news speeches_and_statements],
              },
          },
          "subscription_url" => "http://www.example.com",
        )

        post :create, params: {
          slug: "news-and-communications",
          subscriber_list_params: {},
        }
        expect(subject).to redirect_to("http://www.example.com")
      end


      it "will not include a facet that is not in the signup content item in the redirect" do
        content_store_has_item("/cma-cases", cma_cases_content_item)
        content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
        email_alert_api_has_subscriber_list(
          "tags" => {
            "case_type" => { any: %w[ca98-and-civil-cartels] },
            "format" => { any: %w[cma_case] },
          },
          "subscription_url" => "http://www.example.com",
        )

        post :create, params: {
          slug: "cma-cases",
          subscriber_list_params: { part_of_taxonomy_tree: %w(some-taxon) },
          filter: {
            "case_type" => %w[ca98-and-civil-cartels],
            "case_state" => %w(open),
          },
        }
        expect(subject).to redirect_to("http://www.example.com")
      end
    end
  end

  context "with email_filter_by set to 'facet_values'" do
    describe 'POST "#create"' do
      before do
        content_store_has_item("/find-eu-exit-guidance-business", business_readiness_content_item)
        content_store_has_item("/find-eu-exit-guidance-business/email-signup", business_readiness_signup_content_item)
      end

      it "should call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
        email_alert_api_has_subscriber_list(
          "links" => {
            "facet_values" => { any: %w(aerospace) },
          },
          "subscription_url" => "http://www.itstartshear.com",
          "email_filter_by" => "facet_values",
        )

        allow(EmailAlertListTitleBuilder).to receive(:call)

        post :create, params: {
          slug: "find-eu-exit-guidance-business",
          filter: {
            "sector_business_area" => %w(aerospace),
          },
        }

        expect(EmailAlertListTitleBuilder).to have_received(:call)
      end
    end
  end

  context "with blank email_filter_by" do
    describe 'POST "#create"' do
      it "should not call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
        content_store_has_item("/cma_cases", cma_cases_content_item)
        content_store_has_item("/cma_cases/email-signup", cma_cases_signup_content_item)

        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => { any: %w[cma_case] },
            "case_type" => { any: %w[markets] },
          },
          "subscription_url" => "http://www.gov.uk",
        )

        allow(EmailAlertTitleBuilder).to receive(:call)

        post :create, params: {
          slug: "cma_cases",
          filter: {
            "case_type" => %w[markets],
          },
        }

        expect(EmailAlertTitleBuilder).to have_received(:call)
      end
    end
  end
end
