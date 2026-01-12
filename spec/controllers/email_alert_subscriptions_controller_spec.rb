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
  let(:brexit_taxon_id) { ContentItem::BREXIT_CONTENT_ID }
  let(:org_slug_one) { "department-of-mysteries" }
  let(:org_slug_two) { "gringots" }

  before do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(
        :level_one_taxon_hash,
        content_id: taxon_content_id_one,
        title: "Magical Education",
        child_taxons: [
          FactoryBot.build(:taxon_hash, content_id: taxon_content_id_two, title: "Herbology"),
        ],
      ),
      FactoryBot.build(:level_one_taxon_hash, content_id: brexit_taxon_id, title: "Brexit"),
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  after do
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
        post :create,
             params: {
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
          stub_email_alert_api_creates_subscriber_list(
            "tags" => {
              "case_type" => { any: %w[consumer-enforcement] },
              "format" => { any: %w[cma_case] },
            },
            "slug" => "slug",
          )

          post :create,
               params: {
                 slug: "cma-cases",
                 filter: {
                   "case_type" => %w[consumer-enforcement],
                 },
               }
          expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
        end
      end
    end

    context "when the signup page has 'dynamic' filters (News and Communications)" do
      before do
        stub_content_store_has_item("/news-and-communications", news_and_communications_content_item)
        stub_content_store_has_item("/news-and-communications/email-signup", news_and_communications_signup_content_item)
      end

      it "redirects to the correct email subscription url with subscriber_list_params" do
        stub_email_alert_api_creates_subscriber_list(
          "links" => {
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two, brexit_taxon_id] },
            "content_purpose_subgroup" => { "any" => %w[news speeches_and_statements] },
          },
          "slug" => "slug",
        )

        post :create,
             params: {
               slug: "news-and-communications",
               subscriber_list_params: {
                 "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, brexit_taxon_id, "junk-content-id"],
                 "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
                 "junk_key" => %w[junk-values],
                 "another_junk_key" => "single-junk-value",
               },
             }
        expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
      end

      it "without allowed filters it redirects to the default email subscription url" do
        stub_email_alert_api_creates_subscriber_list(
          "links" => { "content_purpose_subgroup" => { "any" => %w[news speeches_and_statements] } },
          "slug" => "slug",
        )

        post :create,
             params: {
               slug: "news-and-communications",
               subscriber_list_params: {
                 "organisations" => %w[junk-org],
                 "junk_key" => %w[junk-values],
                 "another_junk_key" => "single-junk-value",
               },
             }
        expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
      end
    end

    context "when the signup page has 'option lookup' filters (Policy Papers and Consultations)" do
      before do
        stub_content_store_has_item("/search/policy-papers-and-consultations", policy_papers_finder_content_item)
        stub_content_store_has_item("/search/policy-papers-and-consultations/email-signup", policy_papers_finder_signup_content_item)
      end

      it "redirects to the correct email subscription URL" do
        stub_email_alert_api_creates_subscriber_list(
          "links" => {
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "content_store_document_type" => { "any" => %w[impact_assessment case_study policy_paper] },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
            "content_purpose_supergroup" => { "any" => %w[policy_and_engagement] },
          },
          "slug" => "slug",
        )

        post :create,
             params: {
               slug: "search/policy-papers-and-consultations",
               subscriber_list_params: {
                 "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
                 "content_store_document_type" => %w[impact_assessment case_study policy_paper junk-doc-type],
                 "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
               },
             }
        expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
      end
    end

    context "when facet choices contain filter_values (Research and Statistics)" do
      before do
        stub_content_store_has_item("/search/research-and-statistics", research_and_stats_finder_content_item)
        stub_content_store_has_item("/search/research-and-statistics/email-signup", research_and_stats_finder_signup_content_item)
      end

      it "redirects the user to the subscription URL" do
        stub_email_alert_api_creates_subscriber_list(
          "links" => {
            "content_store_document_type" => {
              "any" => %w[
                statistics
                national_statistics
                statistical_data_set
                official_statistics
                research_for_development_output
                independent_report
                research
              ],
            },
            "organisations" => { "any" => ["content_id_for_#{org_slug_one}", "content_id_for_#{org_slug_two}"] },
            "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
          },
          "slug" => "slug",
        )

        post :create,
             params: {
               slug: "search/research-and-statistics",
               filter: {
                 "content_store_document_type" => %w[statistics_published research junk-doc-type],
               },
               subscriber_list_params: {
                 "content_store_document_type" => %w[statistics_published research junk-doc-type],
                 "organisations" => [org_slug_one, org_slug_two, "junk-organisation"],
                 "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
               },
             }
        expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
      end

      context "when filter and subscriber_list_params params are empty" do
        it "renders the signup page URL again" do
          post :create,
               params: {
                 slug: "search/research-and-statistics",
                 filter: {},
                 subscriber_list_params: {},
               }
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end

      context "when the filter params are not provided" do
        it "redirects the user to the subscription URL" do
          stub_email_alert_api_creates_subscriber_list(
            "links" => {
              "content_store_document_type" => {
                "any" => %w[
                  statistics
                  national_statistics
                  statistical_data_set
                  official_statistics
                  research_for_development_output
                  independent_report
                  research
                ],
              },
              "taxon_tree" => { "all" => [taxon_content_id_one, taxon_content_id_two] },
            },
            "slug" => "slug",
          )

          post :create,
               params: {
                 slug: "search/research-and-statistics",
                 filter: {},
                 subscriber_list_params: {
                   "content_store_document_type" => %w[statistics_published research junk-doc-type],
                   "all_part_of_taxonomy_tree" => [taxon_content_id_one, taxon_content_id_two, "junk-content-id"],
                 },
               }
          expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
        end
      end

      context "when the subscriber_list_params params are not provided" do
        it "redirects the user to the subscription URL" do
          stub_email_alert_api_creates_subscriber_list(
            "links" => {
              "content_store_document_type" => {
                "any" => %w[
                  statistics
                  national_statistics
                  statistical_data_set
                  official_statistics
                  research_for_development_output
                  independent_report
                  research
                ],
              },
            },
            "slug" => "slug",
          )

          post :create,
               params: {
                 slug: "search/research-and-statistics",
                 filter: {
                   "content_store_document_type" => %w[statistics_published research junk-doc-type],
                 },
                 subscriber_list_params: {},
               }
          expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
        end
      end
    end

    context "when additional keys or values are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", cma_cases_signup_content_item)
      end

      it "strips surplus keys or values" do
        stub_email_alert_api_creates_subscriber_list(
          "tags" => {
            "case_type" => { any: %w[consumer-enforcement] },
            "format" => { any: %w[cma_case] },
          },
          "slug" => "slug",
        )
        post :create,
             params: {
               slug: "cma-cases",
               filter: { "case_type" => %w[consumer-enforcement foo], "foo" => %w[mergers] },
               subscriber_list_params: { "case_type" => %w[foo ca98-and-civil-cartels], "foo" => %w[markets] },
               foo: { "filter" => %w[regulatory-references-and-appeals] },
               bar: [{ "case_type" => %w[criminal-cartels] }],
               blah: "criminal-cartels",
               mergers: %w[competition-disqualification],
             }
        expect(subject).to redirect_to("/email/subscriptions/new?topic_id=slug")
      end
    end

    context "when unprocessable keys are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", bad_input_finder_signup_content_item)
      end

      it "redirects the user to the signup page" do
        post :create,
             params: {
               slug: "cma-cases",
               filter: { "evil_key'><script>alert(1)</script>" => %w[mergers] },
             }
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    context "when unprocessable values are provided by the user" do
      before do
        stub_content_store_has_item("/cma-cases", cma_cases_content_item)
        stub_content_store_has_item("/cma-cases/email-signup", bad_input_finder_signup_content_item)
      end

      it "redirects the user to the signup page" do
        post :create,
             params: {
               slug: "cma-cases",
               filter: { "evil_value" => %w('><script>alert(1)</script>) },
             }
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end
  end
end
