require "gds_api/content_store"
require "gds_api/search"
require "gds_api/email_alert_api"

module Services
  def self.content_store
    GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def self.cached_content_item(base_path)
    Rails.cache.fetch("finder-frontend_content_items#{base_path}", expires_in: 5.minutes) do
      GovukStatsd.time("content_store.fetch_request_time") do
        content_store.content_item(base_path).to_h
      end
    end
  end

  def self.rummager
    GdsApi::Search.new(Plek.find("search"))
  end

  def self.email_alert_api
    Services::EmailAlertApi.new
  end

  def self.worldwide_api
    GdsApi.worldwide
  end

  def self.registries
    Registries::BaseRegistries.new
  end

  def self.accounts_api
    Plek.find("account-manager")
  end

  def self.oidc
    OidcClient.new(
      accounts_api,
      ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_ID"),
      ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"),
    )
  end
end
