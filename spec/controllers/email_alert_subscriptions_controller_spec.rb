require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore
include FixturesHelper

describe EmailAlertSubscriptionsController do
  include GovukContentSchemaExamples

  describe 'GET #new' do
    describe "finder email signup item doesn't exist" do
      it 'returns a 404, rather than 5xx' do
        content_store_does_not_have_item('/does-not-exist/email-signup')

        get :new, slug: 'does-not-exist'
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST "#create"' do
    let(:alert_name) { double(:alert_name) }
    let(:alert_identifier) { double(:alert_identifier) }
    let(:delivery_api) { double(:delivery_api) }
    let(:finder) { govuk_content_schema_example('finder').to_hash.merge(title: alert_name) }
    let(:signup_finder) { cma_cases_signup_content_item }
    let(:signup_api_wrapper) {
      double(:signup_api_wrapper, signup_url: 'http://www.example.com')
    }

    before do
      content_store_has_item('/cma-cases', finder)
      content_store_has_item('/cma-cases/email-signup', signup_finder)
      allow(controller).to receive(:email_alert_api).and_return(delivery_api)
      allow(EmailAlertSignupAPI).to receive(:new).and_return(signup_api_wrapper)
    end

    it 'redirects to the correct email subscription url' do
      post :create, slug: 'cma-cases'
      expect(subject).to redirect_to('http://www.example.com')
    end
  end
end
