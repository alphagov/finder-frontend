require 'digest'

class EmailAlertSubscriberListService
  def initialize(options)
    @options = options
  end

  def cacheable_subscriber_list
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      Services.email_alert_api.find_or_create_subscriber_list(options).to_h
    end
  end

private

  def cache_key
    Digest::SHA256.hexdigest(options.to_s)
  end

  attr_reader :options
end
