require 'rails_helper'

describe EmailAlertSubscriptionsController do

  describe 'POST "#create"' do
    let(:schema_hash) {
      {
        'facets' => [],
      }
    }
    let(:schema) { double(:schema, schema_hash: schema_hash) }
    let(:alert_name) { double(:alert_name) }
    let(:alert_identifier) { double(:alert_identifier) }
    let(:delivery_api) { double(:delivery_api) }
    let(:signup_api_wrapper) {
      double(:signup_api_wrapper,
        signup_url: 'http://www.example.com'
      )
    }
    let(:artefact_api_wrapper) {
      double(:artefact_api_wrapper,
        get: double(:artefact),
      )
    }
    let(:signup_page) {
      double(:signup_page,
        title: alert_name,
        alert_identifier: alert_identifier,
        emailable_facet_keys: [],
      )
    }

    before do
      allow(FinderFrontend).to receive(:get_schema).with('cma-cases').and_return(schema)
      allow(controller).to receive(:delivery_api).and_return(delivery_api)
      allow(EmailSignupPage).to receive(:new).and_return(signup_page);
      allow(ArtefactAPI).to receive(:new).and_return(artefact_api_wrapper)
      allow(EmailAlertSignupAPI).to receive(:new).with(
        delivery_api: delivery_api,
        alert_identifier: alert_identifier,
        alert_name: alert_name
      ).and_return(signup_api_wrapper)
    end

    it 'redirects to the correct email subscription url' do
      post :create, slug: 'cma-cases'
      expect(subject).to redirect_to('http://www.example.com')
    end
  end

end
