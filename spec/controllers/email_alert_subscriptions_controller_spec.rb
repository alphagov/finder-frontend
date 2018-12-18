require 'spec_helper'
require 'gds_api/test_helpers/content_store'
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSubscriptionsController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi
  include FixturesHelper
  include GovukContentSchemaExamples
  render_views

  let(:signup_finder) { cma_cases_signup_content_item }

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

    it "fails if the relevant filters are not provided" do
      post :create, params: { slug: 'cma-cases' }
      expect(response).to be_successful
      expect(response).to render_template('new')
    end

    it 'redirects to the correct email subscription url' do
      email_alert_api_has_subscriber_list(
        "tags" => {
          "case_type" => ['ca98-and-civil-cartels'],
          "format" => [finder.dig('details', 'filter', 'document_type')]
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
            "case_type" => ['ca98-and-civil-cartels'],
            "case_state" => %w(open),
            "format" => [finder.dig('details', 'filter', 'document_type')]
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

      it 'redirects to the correct email subscription url with hidden_params' do
        taxonomy_signup_finder = signup_finder.tap do |content_item|
          content_item['details']['email_filter_facets'] << {
            'facet_key' => 'filter_part_of_taxonomy_tree',
            'facet_id' => 'filter_part_of_taxonomy_tree',
            'facet_name' => 'Taxonomy'
          }
        end

        content_store_has_item('/cma-cases/email-signup', taxonomy_signup_finder)
        email_alert_api_has_subscriber_list(
          'tags' => {
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
            'format' => [finder.dig('details', 'filter', 'document_type')],
            'filter_part_of_taxonomy_tree[]' => ['some-taxon'],
          },
          'subscription_url' => 'http://www.example.com'
        )
        post :create, params: {
          slug: 'cma-cases',
          hidden_params: { filter_part_of_taxonomy_tree: %w(some-taxon) },
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
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
            'format' => [finder.dig('details', 'filter', 'document_type')],
          },
          'subscription_url' => 'http://www.example.com'
        )
        post :create, params: {
          slug: 'cma-cases',
          hidden_params: { filter_part_of_taxonomy_tree: %w(some-taxon) },
          filter: {
            'case_type' => ['ca98-and-civil-cartels'],
            'case_state' => %w(open),
          }
        }
        expect(subject).to redirect_to('http://www.example.com')
      end
    end
  end
end
