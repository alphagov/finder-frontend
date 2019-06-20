# typed: true
require 'gds_api/content_store'
require 'gds_api/rummager'
require 'gds_api/email_alert_api'

module Services
  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def self.cached_content_item(base_path)
    Rails.cache.fetch("finder-frontend_content_items#{base_path}", expires_in: 5.minutes) do
      GovukStatsd.time("content_store.fetch_request_time") do
        content_store.content_item(base_path).to_h
      end
    end
  end

  def self.rummager
    @rummager ||= GdsApi::Search.new(Plek.find("search"))
  end

  def self.email_alert_api
    @email_alert_api ||= GdsApi::EmailAlertApi.new(
      Plek.find("email-alert-api"),
      bearer_token: ENV.fetch("EMAIL_ALERT_API_BEARER_TOKEN", "wubbalubbadubdub")
    )
  end

  def self.worldwide_api
    @worldwide_api ||= GdsApi::Worldwide.new(Plek.find('whitehall-admin'))
  end

  def self.registries
    @registries ||= Registries::BaseRegistries.new
  end
end
