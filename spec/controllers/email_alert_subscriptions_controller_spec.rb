# typed: false
require 'spec_helper'
require "helpers/taxonomy_spec_helper"
require "helpers/registry_spec_helper"
require 'gds_api/test_helpers/content_store'
require 'gds_api/test_helpers/email_alert_api'

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
      {
        content_id: content_id_one,
        title: top_level_taxon_one_title
      },
      {
        content_id: content_id_two,
        title: top_level_taxon_two_title
      }
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  describe 'GET #new' do
    describe "finder email signup item doesn't exist" do
      it 'returns a 404, rather than 5xx' do
        content_store_does_not_have_item('/does-not-exist/email-signup')
        get :new, params: { slug: 'does-not-exist' }
        expect(response.status).to eq(404)
      end
    end

    describe "finder email signup item does exist" do
      it 'returns a success' do
        content_store_has_item('/does-exist/email-signup', signup_finder)
        get :new, params: { slug: 'does-exist' }

        expect(response).to be_successful
      end
    end
  end

  describe 'POST "#create"' do
    let(:finder) { govuk_content_schema_example('finder').to_hash.merge(title: 'alert-name') }

    before do
      content_store_has_item('/cma-cases', finder)
      content_store_has_item('/cma-cases/email-signup', signup_finder)
    end

    context "finder has default filters" do
      let(:signup_finder) {
        cma_cases_signup_content_item.to_hash.merge("details" => {
          "filter" => { "content_purpose_supergroup" => 'news-and-communications' },
        })
      }

      it "does not fail if no other attributes are provided" do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => { any: %w(mosw_report) },
            "content_purpose_supergroup" => { any: %w(news-and-communications) },
          },
          "subscription_url" => 'http://www.example.com',
        )

        post :create, params: { slug: 'cma-cases' }
        expect(subject).to redirect_to('http://www.example.com')
      end
    end


    it "fails if the relevant filters are not provided" do
      post :create, params: { slug: 'cma-cases' }
      expect(response).to be_successful
      expect(response).to render_template('new')
    end

    it 'redirects to the correct email subscription url' do
      email_alert_api_has_subscriber_list(
        "tags" => {
          "case_type" => { any: ['ca98-and-civil-cartels'] },
          "format" => { any: [finder.dig('details', 'filter', 'document_type')] },
        },
        "subscription_url" => 'http://www.example.com'
      )

      post :create, params: {
        slug: 'cma-cases',
        filter: {
          'case_type' => ['ca98-and-civil-cartels']
        }
      }
      expect(subject).to redirect_to('http://www.example.com')
    end
  end

  context "with a multi facet signup" do
    let(:signup_finder) { cma_cases_with_multi_facets_signup_content_item }

    describe 'POST "#create"' do
      let(:finder) { govuk_content_schema_example('finder').to_hash.merge(title: 'alert-name') }

      before do
        content_store_has_item('/cma-cases', finder)
      end

      it 'redirects to the correct email subscription url' do
        content_store_has_item('/cma-cases/email-signup', signup_finder)
        email_alert_api_has_subscriber_list(
          "tags" => {
            "case_type" => { any: ['ca98-and-civil-cartels'] },
            "case_state" => { any: %w(open) },
            "format" => { any: [finder.dig('details', 'filter', 'document_type')] },
          },
          "subscription_url" => 'http://www.example.com'
        )

        post :create, params: {
          slug: 'cma-cases',
          filter: {
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
          }
        }

        expect(subject).to redirect_to('http://www.example.com')
      end

      it 'redirects to the correct email subscription url with subscriber_list_params' do
        taxonomy_signup_finder = signup_finder.tap do |content_item|
          content_item['details']['email_filter_facets'] << {
            'facet_key' => 'part_of_taxonomy_tree',
            'facet_id' => 'part_of_taxonomy_tree',
            'facet_name' => 'Taxonomy'
          }
        end

        content_store_has_item('/cma-cases/email-signup', taxonomy_signup_finder)
        email_alert_api_has_subscriber_list(
          'tags' => {
            'case_type' => { any: ['ca98-and-civil-cartels'] },
            'case_state' => { any: %w(open) },
            'format' => { any: [finder.dig('details', 'filter', 'document_type')] },
            'part_of_taxonomy_tree[]' => { any: ['some-taxon'] },
          },
          'subscription_url' => 'http://www.example.com'
        )

        post :create, params: {
          slug: 'cma-cases',
          subscriber_list_params: { part_of_taxonomy_tree: %w(some-taxon) },
          filter: {
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
          }
        }
        expect(subject).to redirect_to('http://www.example.com')
      end


      it 'will not include a facet that is not in the signup content item in the redirect' do
        content_store_has_item('/cma-cases/email-signup', signup_finder)
        email_alert_api_has_subscriber_list(
          'tags' => {
            'case_type' => { any: ['ca98-and-civil-cartels'] },
            'case_state' => { any: %w(open) },
            'format' => { any: [finder.dig('details', 'filter', 'document_type')] },
          },
          'subscription_url' => 'http://www.example.com'
        )

        post :create, params: {
          slug: 'cma-cases',
          subscriber_list_params: { part_of_taxonomy_tree: %w(some-taxon) },
          filter: {
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
          }
        }
        expect(subject).to redirect_to('http://www.example.com')
      end
    end
  end

  context "with email_filter_by set to 'facet_values'" do
    describe 'POST "#create"' do
      let(:finder) { business_readiness_content_item }
      let(:signup_finder) { business_readiness_signup_content_item }

      before do
        content_store_has_item('/find-eu-exit-guidance-business', finder)
      end

      it "should call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
        content_store_has_item('/find-eu-exit-guidance-business/email-signup', signup_finder)
        email_alert_api_has_subscriber_list(
          'links' => {
            'facet_values' => { any: %w(aerospace) },
          },
          'subscription_url' => 'http://www.itstartshear.com',
          'email_filter_by' => 'facet_values'
        )

        allow(EmailAlertListTitleBuilder).to receive(:call)

        post :create, params: {
          slug: 'find-eu-exit-guidance-business',
          filter: {
            'sector_business_area' => %w(aerospace),
          }
        }

        expect(EmailAlertListTitleBuilder).to have_received(:call)
      end
    end
  end

  context "with blank email_filter_by" do
    describe 'POST "#create"' do
      let(:finder) { govuk_content_schema_example('finder') }
      let(:signup_finder) {
        cma_cases_signup_content_item.to_hash.merge("details" => {
          "filter" => { "content_purpose_supergroup" => 'news-and-communications' },
        })
      }

      before do
        content_store_has_item('/find-eu-exit-guidance-business', finder)
      end

      it "should not call EmailAlertListTitleBuilder instead of EmailAlertTitleBuilder" do
        content_store_has_item('/find-eu-exit-guidance-business/email-signup', signup_finder)
        email_alert_api_has_subscriber_list(
          'tags' => {
            'format' => { any: %w(mosw_report) },
            'content_purpose_supergroup' => { any: %w(news-and-communications) },
          },
          'subscription_url' => 'http://www.itstartshear.com'
        )

        allow(EmailAlertTitleBuilder).to receive(:call)

        post :create, params: {
          slug: 'find-eu-exit-guidance-business',
          filter: {
            'sector_business_area' => %w(aerospace),
          }
        }

        expect(EmailAlertTitleBuilder).to have_received(:call)
      end
    end
  end
end
