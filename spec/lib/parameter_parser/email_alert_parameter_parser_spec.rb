require "spec_helper"
require "gds_api/test_helpers/content_store"

describe ParameterParser::EmailAlertParameterParser do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include TaxonomySpecHelper
  include RegistrySpecHelper

  subject(:parser) { described_class.new(content_item, filter_params, user_params) }

  let(:content_item) { { "details" => {} } }
  let(:filter_params) { {} }
  let(:user_params) { ActionController::Parameters.new(params) }
  let(:params) { {} }
  let(:signup_finder) { cma_cases_signup_content_item }
  let(:taxon_content_id_one) { "magical-education" }
  let(:taxon_content_id_two) { "herbology" }

  before do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: taxon_content_id_one, title: "Magical Education"),
      FactoryBot.build(:level_one_taxon_hash, content_id: taxon_content_id_two, title: "Herbology"),
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  describe "#valid?" do
    subject(:valid) { parser.valid? }

    let(:error_messages) { parser.errors.full_messages }

    context "when there are no permitted facets" do
      context "with no user params provided" do
        it { is_expected.to be true }
      end

      context "with good params provided" do
        let(:params) { { "filter" => { foo: "bar", bar: %w[foo] } } }

        it { is_expected.to be true }
      end

      context "with bad params provided" do
        let(:params) { { "filter" => { "foo": %w('><script>alert(1)</script>), bar: %w[foo] } } }

        it { is_expected.to be true }
      end
    end

    context "when there are permitted facets (CMA cases)" do
      let(:content_item) { cma_cases_signup_content_item }

      context "with no user params provided" do
        it { is_expected.to be true }
      end

      context "with good params provided" do
        let(:params) do
          {
            "filter" => { "case_type" => %w[ca98-and-civil-cartels consumer-enforcement] },
          }
        end

        it { is_expected.to be true }
      end

      context "with unpermitted params provided" do
        let(:params) { { "filter" => { "foo": "bar", bar: %w[foo] } } }
        let(:filter_params) { { "subscriber_list_params" => { foo: "bar", bar: %w[foo] } } }

        it { is_expected.to be true }
      end

      context "with bad keys provided in params" do
        let(:params) { { "filter" => { "'><script>alert(1)</script>": %w[foo], bar: %w[foo] } } }

        it { is_expected.to be true }
      end

      context "with bad values provided in params" do
        let(:params) { { "filter" => { "foo": %w('><script>alert(1)</script>), bar: %w[foo] } } }

        it { is_expected.to be true }
      end
    end

    context "when there are bad facets in the content item" do
      let(:content_item) { bad_input_finder_signup_content_item }

      context "with no user params provided" do
        it { is_expected.to be true }
      end

      context "with good params provided" do
        let(:params) { { "filter" => { "good_value": %w[competition-disqualification], bar: %w[foo] } } }

        it { is_expected.to be true }
      end

      context "with bad keys provided in params" do
        let(:params) { { "filter" => { "evil_key'><script>alert(1)</script>": %w[markets] } } }

        it { is_expected.to be false }
      end

      context "with bad values provided in params" do
        let(:params) { { "filter" => { "evil_value": %w('><script>alert(1)</script>) } } }

        it { is_expected.to be false }
      end
    end
  end

  describe "#applied_filters" do
    subject(:applied_filters) { parser.applied_filters }

    context "when there are no permitted facets" do
      context "with no user params provided" do
        it { is_expected.to eq({}) }
      end

      context "with user params provided" do
        let(:params) { { "filter" => { foo: "bar", bar: %w[foo] } } }

        it { is_expected.to eq({}) }
      end

      context "with filter params provided" do
        let(:filter_params) { { "subscriber_list_params" => { foo: "bar", bar: %w[foo] } } }

        it { is_expected.to eq({}) }
      end
    end

    context "when there are permitted facets (CMA Cases)" do
      let(:content_item) { cma_cases_signup_content_item }

      context "with no user params provided" do
        it { is_expected.to eq({}) }
      end

      context "with good params provided" do
        let(:params) do
          {
            "filter" => { "case_type" => %w[ca98-and-civil-cartels consumer-enforcement] },
          }
        end

        it { is_expected.to eq("case_type" => %w[ca98-and-civil-cartels consumer-enforcement]) }
      end

      context "with unpermitted params provided" do
        let(:params) do
          {
            "filter" => {
              "foo" => "bar",
              "bar" => %w[foo],
              "case_type" => %w[ca98-and-civil-cartels consumer-enforcement bad-value],
            },
          }
        end

        it { is_expected.to eq("case_type" => %w[ca98-and-civil-cartels consumer-enforcement]) }
      end
    end

    context "when there are 'dynamic' facets (News and Communications)" do
      let(:content_item) { news_and_communications_signup_content_item }

      context "with no user params provided" do
        it { is_expected.to eq({}) }
      end

      context "with filter params provided" do
        let(:params) do
          {
            "filter" => { "people" => %w[albus-dumbledore foo bar] },
          }
        end

        it { is_expected.to eq("people" => %w[albus-dumbledore]) }
      end

      context "with subscriber_list_params params provided" do
        let(:filter_params) do
          {
            "subscriber_list_params" => {
              "people" => %w[albus-dumbledore foo bar],
              "organisations" => %w[department-of-mysteries gringots junk-organisation],
              "junk_key" => %w[junk-values],
              "another_junk_key" => "single-junk-value",
            },
          }
        end

        it { is_expected.to eq("organisations" => %w[department-of-mysteries gringots], "people" => %w[albus-dumbledore]) }
      end

      context "with both subscriber_list_params and params provided" do
        let(:params) do
          {
            "filter" => { "people" => %w[albus-dumbledore harry-potter foo bar] },
          }
        end
        let(:filter_params) do
          {
            "subscriber_list_params" => {
              "people" => %w[cornelius-fudge foo bar],
              "organisations" => %w[department-of-mysteries gringots junk-organisation],
              "junk_key" => %w[junk-values],
              "another_junk_key" => "single-junk-value",
            },
          }
        end

        it { is_expected.to eq("organisations" => %w[department-of-mysteries gringots], "people" => %w[albus-dumbledore harry-potter]) }
      end
    end

    context "when there are 'option lookup' facets (Policy Papers and Consultations)" do
      let(:content_item) { policy_papers_finder_signup_content_item }
      let(:filter_params) do
        {
          "subscriber_list_params" => {
            "people" => %w[cornelius-fudge foo bar],
            "organisations" => %w[department-of-mysteries gringots junk-organisation],
            "junk_key" => %w[junk-values],
            "another_junk_key" => "single-junk-value",
          },
        }
      end

      it { is_expected.to eq("organisations" => %w[department-of-mysteries gringots], "people" => %w[cornelius-fudge]) }
    end

    context "when there are facets containing filter_values (Research and Statistics)" do
      let(:content_item) { research_and_stats_finder_signup_content_item }
      let(:filter_params) do
        {
          "subscriber_list_params" => {
            "content_store_document_type" => %w[statistics_published junk-doc-type],
            "organisations" => %w[department-of-mysteries junk-organisation],
            "junk_key" => %w[junk-values],
            "another_junk_key" => "single-junk-value",
          },
        }
      end

      it { is_expected.to eq("content_store_document_type" => %w[statistics_published], "organisations" => %w[department-of-mysteries]) }
    end
  end
end
