require 'rails_helper'
require 'email_alert_signup_api'

describe EmailAlertSignupAPI do

  let(:delivery_api)      { double(:delivery_api) }
  let(:alert_identifier)  { double(:alert_identifier) }
  let(:alert_name)        { double(:alert_name) }

  subject(:signup_api_wrapper) {
    EmailAlertSignupAPI.new(
      delivery_api: delivery_api,
      alert_name: alert_name,
      alert_identifier: alert_identifier
    )
  }

  describe '#signup_url' do
    let(:mock_signup_url) { double(:mock_signup_url) }

    before do
      allow(delivery_api).to receive(:topic)
      allow(delivery_api).to receive(:signup_url).and_return(mock_signup_url)
    end

    it 'asks govuk_delivery to create a topic' do
      signup_api_wrapper.signup_url
      expect(delivery_api).to have_received(:topic).with(alert_identifier, alert_name)
    end

    it 'asks govuk_delivery to fetch the subscription url for a topic' do
      signup_api_wrapper.signup_url
      expect(delivery_api).to have_received(:signup_url).with(alert_identifier)
    end

    it 'returns the url govuk_delivery gives back' do
      expect(signup_api_wrapper.signup_url).to eql mock_signup_url
    end
  end

end
