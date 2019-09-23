require "digest"

class Services::EmailAlertApi
  delegate :find_or_create_subscriber_list,
           to: :service

  def find_or_create_subscriber_list_cached(options)
    Rails.cache.fetch(cache_key(options), expires_in: 1.hour) do
      find_or_create_subscriber_list(options).to_h
    end
  end

private

  def service
    @service ||= GdsApi.email_alert_api
  end

  def cache_key(options)
    Digest::SHA256.hexdigest(options.to_s)
  end
end
