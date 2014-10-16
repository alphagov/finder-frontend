require 'rails_helper'
require 'email_alert_signup_api'

describe EmailAlertSignupAPI do

  let(:email_alert_api)   { double(:email_alert_api) }
  let(:alert_name)        { double(:alert_name) }
  let(:tag_set)           { double(:tag_set) }

  subject(:signup_api_wrapper) {
    EmailAlertSignupAPI.new(
      email_alert_api: email_alert_api,
      title: alert_name,
      tags: tag_set
    )
  }

  describe '#signup_url' do
    let(:signup_url) { double(:signup_url) }
    let(:response) {
      double(:response,
        subscription_url: signup_url
      )
    }

    before do
      allow(email_alert_api).to receive(:find_or_create_subscriber_list).and_return(response)
    end

    it 'returns the url govuk_delivery gives back' do
      expect(signup_api_wrapper.signup_url).to eq signup_url
    end
  end

end
