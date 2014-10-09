require "singleton"
require "gds_api/email_alert_api"

module EmailAlertAPIHelpers

  class FakeEmailAlertAPI
    include Singleton

    def find_or_create_subscriber_list(feed_urls)
    end
  end

  def stub_email_alert_api
    allow(GdsApi::EmailAlertApi).to receive(:new)
      .and_return(fake_email_alert_api)

    allow(fake_email_alert_api).to receive(:find_or_create_subscriber_list)
      .and_return(
        OpenStruct.new(subscription_url: "/drug-device-alerts/email-signup")
      )
  end

  def reset_email_alert_api_stubs_and_messages
    RSpec::Mocks.space.proxy_for(email_alert_api).reset
    stub_email_alert_api
  end

  def fake_email_alert_api
    FakeEmailAlertAPI.instance
  end
end
