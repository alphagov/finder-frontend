require "singleton"
require "gds_api/gov_uk_delivery"

module DeliveryAPIHelpers

  class FakeDeliveryAPI
    include Singleton

    def signup_url(feed_urls)
      "/drug-device-alerts/email-signup"
    end

    def topic(feed_urls, title)
    end
  end

  def stub_delivery_api
    allow(GdsApi::GovUkDelivery).to receive(:new)
      .and_return(fake_delivery_api)

    allow(fake_delivery_api).to receive(:signup_url).and_call_original
    allow(fake_delivery_api).to receive(:topic).and_call_original
  end

  def reset_delivery_api_stubs_and_messages
    RSpec::Mocks.space.proxy_for(delivery_api).reset
    stub_delivery_api
  end

  def fake_delivery_api
    FakeDeliveryAPI.instance
  end
end
