require 'rails_helper'

describe EmailAlertSubscriptionsController do

  describe 'POST "#create"' do
    let(:alert_name) { double(:alert_name) }
    let(:alert_identifier) { double(:alert_identifier) }
    let(:delivery_api) { double(:delivery_api) }
    let(:finder) {
      double(:finder,
        name: alert_name
      )
    }
    let(:signup_api_wrapper) {
      double(:signup_api_wrapper,
        signup_url: 'http://www.example.com'
      )
    }

    before do
      allow(controller).to receive(:delivery_api).and_return(delivery_api)
      allow(controller).to receive(:finder_url_for_alert_type).and_return(alert_identifier)
      allow(Finder).to receive(:get).with('cma-cases').and_return(finder)
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
