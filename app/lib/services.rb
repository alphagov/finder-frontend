require 'gds_api/content_store'
require 'gds_api/rummager'
require 'gds_api/email_alert_api'

module Services
  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(
      Plek.find("content-store"),
      disable_cache: Rails.env.development?
    )
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(
      Plek.find("search"),
      disable_cache: Rails.env.development?
    )
  end

  def self.email_alert_api
    @email_alert_api ||= GdsApi::EmailAlertApi.new(
      Plek.find("email-alert-api")
    )
  end
end
