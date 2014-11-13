require 'spec_helper'
require 'email_alert_signup_api'

describe EmailAlertSignupAPI do

  let(:email_alert_api)      { double(:email_alert_api) }
  let(:attributes)  {
    {
      "format" => "test-reports",
      "report_type" => ["first", "second"],
    }
  }

  subject(:signup_api_wrapper) {
    EmailAlertSignupAPI.new(
      email_alert_api: email_alert_api,
      attributes: attributes,
    )
  }

  describe '#signup_url' do
    let(:subscription_url) { "http://www.example.org/list-id/signup" }
    let(:mock_subscriber_list) { double(:mock_subscriber_list, subscription_url: subscription_url) }
    let(:mock_response) { double(:mock_response, subscriber_list: mock_subscriber_list)}

    before do
      allow(email_alert_api).to receive(:find_or_create_subscriber_list).and_return(mock_response)
    end

    it 'asks govuk_delivery to find or create the subscriber list' do
      signup_api_wrapper.signup_url

      expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with("tags" => attributes)
    end

    it 'returns the url govuk_delivery gives back' do
      expect(signup_api_wrapper.signup_url).to eql subscription_url
    end
  end

end
