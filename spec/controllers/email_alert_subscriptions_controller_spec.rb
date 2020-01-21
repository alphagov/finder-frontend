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
  let(:taxon_content_id_one) { "magical-education" }
  let(:taxon_content_id_two) { "herbology" }
  let(:brexit_taxon_id) { "d6c2de5d-ef90-45d1-82d4-5f2438369eea" }
  let(:org_slug_one) { "department-of-mysteries" }
  let(:org_slug_two) { "gringots" }

  before do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: taxon_content_id_one, title: "Magical Education", child_taxons: [
        FactoryBot.build(:taxon_hash, content_id: taxon_content_id_two, title: "Herbology"),
      ]),
      FactoryBot.build(:level_one_taxon_hash, content_id: brexit_taxon_id, title: "Brexit"),
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  after :each do
    Rails.cache.clear
  end

  describe "GET #new" do
    describe "finder email signup item doesn't exist" do
      it "returns a 404, rather than 5xx" do
        stub_content_store_does_not_have_item("/does-not-exist/email-signup")
        get :new, params: { slug: "does-not-exist" }
        expect(response.status).to eq(404)
      end
    end

    describe "finder email signup item does exist" do
      before do
        stub_content_store_has_item("/does-exist/email-signup", signup_finder)
      end
      it "returns a success" do
        get :new, params: { slug: "does-exist" }

        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    context "when finder email signup item doesn't exist" do
      before do
        stub_content_store_does_not_have_item("/does-not-exist/email-signup")
      end
      it "returns a 404" do
        get :new, params: { slug: "does-not-exist" }
        expect(response.status).to eq(404)
      end
    end

    context "when Email Alert API returns a 422 error" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
      end

      it "returns a 200 and displays the signup page" do
        stub_any_email_alert_api_call.to_return(status: 422)
        post :create, params: {
          slug: "cma-cases",
          filter: { "case_type" => %w[overriding-case-type] },
        }
        expect(response).to be_successful
        expect(response).to render_template("new")
      end
    end

    context "when the finder signup page has filters (CMA Cases)" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
      end

      context "when a required filter is not provided" do
        it "returns the user to the signup page with an error" do
          post :create, params: { slug: "cma-cases" }
          expect(response).to be_successful
          expect(response).to render_template("new")
        end
      end

      context "when all required filters are provided" do
        it "redirects to the subscription url" do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "case_type" => { any: %w[consumer-enforcement] },
              "format" => { any: %w[cma_case] },
            },
            "subscription_url" => "http://www.gov.uk/subscription-to-cma-cases",
          )

          post :create, params: {
            slug: "cma-cases",
            filter: {
              "case_type" => %w[consumer-enforcement],
            },
          }
          expect(subject).to redirect_to("http://www.gov.uk/subscription-to-cma-cases")
        end
      end
    end

    context "when the signup page has 'dynamic' filters (News and Communications)" do
      before do
        stub_content_store_has_item("/news-and-communications", news_and_communications_content_item)
        stub_content_store_has_item("/news-and-communications/email-signup", news_and_communications_signup_content_item)
      end

      it "redirects to the correct email subscription url with subscriber_list_params" do
        email_alert_api_has_subscriber_list(
          "links" => {
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two, brexit_taxon_id] },
            "content_purpose_subgroup" => { "any" => %w(news speeches_and_statements) },
          },
          "subscription_url" => "http://www.gov.uk/subscription/news",
        )

        post :create, params: {
          slug: "news-and-communications",
          subscriber_list_params: {
            "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, brexit_taxon_id, "junk-content-id"],
            "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
            "junk_key" => %w(junk-values),
            "another_junk_key" => "single-junk-value",
          },
        }
        expect(subject).to redirect_to("http://www.gov.uk/subscription/news")
      end

      it "without allowed filters it redirects to the default email subscription url" do
        email_alert_api_has_subscriber_list(
          "links" => { "content_purpose_subgroup" => { "any" => %w(news speeches_and_statements) } },
          "subscription_url" => "http://www.gov.uk/subscription/default-news",
        )

        post :create, params: {
          slug: "news-and-communications",
          subscriber_list_params: {
            "organisations" => %w(junk-org),
            "junk_key" => %w(junk-values),
            "another_junk_key" => "single-junk-value",
          },
        }
        expect(subject).to redirect_to("http://www.gov.uk/subscription/default-news")
      end
    end

    context "when the signup page has 'option lookup' filters (Policy Papers and Consultations)" do
      before do
        stub_content_store_has_item("/search/policy-papers-and-consultations", policy_papers_finder_content_item)
        stub_content_store_has_item("/search/policy-papers-and-consultations/email-signup", policy_papers_finder_signup_content_item)
      end

      it "redirects to the correct email subscription URL" do
        email_alert_api_has_subscriber_list(
          "links" => {
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "content_store_document_type" => { "any" => %w(impact_assessment case_study policy_paper) },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
            "content_purpose_supergroup" => { "any" => %w(policy_and_engagement) },
          },
          "subscription_url" => "http://www.gov.uk/subscription/policy-papers-and-consultations",
        )

        post :create, params: {
          slug: "search/policy-papers-and-consultations",
          subscriber_list_params: {
            "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
            "content_store_document_type" => %w(impact_assessment case_study policy_paper junk-doc-type),
            "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
          },
        }
        expect(subject).to redirect_to("http://www.gov.uk/subscription/policy-papers-and-consultations")
      end
    end

    context "when facet choices contain filter_values (Research and Statistics)" do
      before do
        stub_content_store_has_item("/search/research-and-statistics", research_and_stats_finder_content_item)
        stub_content_store_has_item("/search/research-and-statistics/email-signup", research_and_stats_finder_signup_content_item)
      end

      it "will redirect the user to the subscription URL" do
        email_alert_api_has_subscriber_list(
          "links" => {
            "content_store_document_type" => {
              "any" => %w(
                statistics national_statistics statistical_data_set official_statistics
                dfid_research_output independent_report research
              ),
            },
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
          },
          "subscription_url" => "http://www.gov.uk/subscription/research-and-stats",
        )

        post :create, params: {
          slug: "search/research-and-statistics",
          filter: {
            "content_store_document_type" => %w[statistics_published research junk-doc-type],
          },
          subscriber_list_params: {
            "content_store_document_type" => %w(statistics_published research junk-doc-type),
            "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
            "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
          },
        }
        expect(subject).to redirect_to("http://www.gov.uk/subscription/research-and-stats")
      end

      context "when filter and subscriber_list_params params are empty" do
        it "will render the signup page URL again" do
          post :create, params: {
            slug: "search/research-and-statistics",
            filter: {},
            subscriber_list_params: {},
          }
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end

      context "when the filter params are not provided" do
        it "will redirect the user to the subscription URL" do
          email_alert_api_has_subscriber_list(
            "links" => {
              "content_store_document_type" => {
                "any" => %w(
                  statistics national_statistics statistical_data_set official_statistics
                  dfid_research_output independent_report research
                ),
              },
              "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
            },
            "subscription_url" => "http://www.gov.uk/subscription/research-and-stats",
          )

          post :create, params: {
            slug: "search/research-and-statistics",
            filter: {},
            subscriber_list_params: {
              "content_store_document_type" => %w(statistics_published research junk-doc-type),
              "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
            },
          }
          expect(subject).to redirect_to("http://www.gov.uk/subscription/research-and-stats")
        end
      end

      context "when the subscriber_list_params params are not provided" do
        it "will redirect the user to the subscription URL" do
          email_alert_api_has_subscriber_list(
            "links" => {
              "content_store_document_type" => {
                "any" => %w(
                  statistics national_statistics statistical_data_set official_statistics
                  dfid_research_output independent_report research
                ),
              },
            },
            "subscription_url" => "http://www.gov.uk/subscription/research-and-stats",
          )

          post :create, params: {
            slug: "search/research-and-statistics",
            filter: {
              "content_store_document_type" => %w[statistics_published research junk-doc-type],
            },
            subscriber_list_params: {},
          }
          expect(subject).to redirect_to("http://www.gov.uk/subscription/research-and-stats")
        end
      end
    end

    context "when additional keys or values are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
      end
      it "will strip surplus keys or values" do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "case_type" => { any: %w[consumer-enforcement] },
            "format" => { any: %w[cma_case] },
          },
          "subscription_url" => "http://www.gov.uk/subscription-to-cma-cases",
        )
        post :create, params: {
          slug: "cma-cases",
          filter: { "case_type" => %w[consumer-enforcement foo], "foo" => %w(mergers) },
          subscriber_list_params: { "case_type" => %w[foo ca98-and-civil-cartels], "foo" => %w(markets) },
          foo: { "filter" => %w[regulatory-references-and-appeals] },
          bar: [{ "case_type" => %w[criminal-cartels] }],
          blah: "criminal-cartels",
          mergers: %w[competition-disqualification],
        }
        expect(subject).to redirect_to("http://www.gov.uk/subscription-to-cma-cases")
      end
    end

    context "when unprocessable keys are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", bad_input_finder_signup_content_item)
      end
      it "will redirect the user to the signup page" do
        post :create, params: {
          slug: "cma-cases",
          filter: { "evil_key'><script>alert(1)</script>" => %w(mergers) },
        }
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    context "when unprocessable keys are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", bad_input_finder_signup_content_item)
      end
      it "will redirect the user to the signup page" do
        post :create, params: {
          slug: "cma-cases",
          filter: { "evil_value" => %w('><script>alert(1)</script>) },
        }
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    # TODO: Remove email_filter_by key
    context "with email_filter_by set to 'facet_values'" do
      it "should call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
        stub_content_store_has_item("/find-eu-exit-guidance-business", business_readiness_content_item)
        stub_content_store_has_item("/find-eu-exit-guidance-business/email-signup", business_readiness_signup_content_item)
        email_alert_api_has_subscriber_list(
          "links" => {
            "facet_values" => { any: %w(24fd50fa-6619-46ca-96cd-8ce90fa076ce) },
          },
          "subscription_url" => "http://www.gov.uk/subscription/find-eu-exit-guidance-business",
          "email_filter_by" => "facet_values",
        )

        allow(EmailAlertListTitleBuilder).to receive(:call)

        post :create, params: {
          slug: "find-eu-exit-guidance-business",
          filter: {
            "sector_business_area" => %w(24fd50fa-6619-46ca-96cd-8ce90fa076ce),
          },
        }

        expect(EmailAlertListTitleBuilder).to have_received(:call)
      end

      context "with blank email_filter_by" do
        before do
          stub_content_store_has_item("/cma_cases", cma_cases_content_item)
          stub_content_store_has_item("/cma_cases/email-signup", cma_cases_signup_content_item)
        end

        it "should not call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: %w[cma_case] },
              "case_type" => { any: %w[markets] },
            },
            "subscription_url" => "http://www.gov.uk/subscription/cma-markets",
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
end
