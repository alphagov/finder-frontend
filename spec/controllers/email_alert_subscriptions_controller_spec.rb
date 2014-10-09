require 'rails_helper'

describe EmailAlertSubscriptionsController do

  describe 'POST "#create"' do
    let(:redirect_url) { "ww.google.com" }
    let(:signup_api) {
      double(:signup_api,
        signup_url: redirect_url
      )
    }

    before do
      allow(controller).to receive(:email_alert_signup_api).and_return(signup_api)
    end

    it 'redirects to the correct email subscription url' do
      post :create, slug: 'cma-cases'
      expect(subject).to redirect_to(redirect_url)
    end
  end

end
