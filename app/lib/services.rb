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
        content_item = content_store.content_item(base_path)
        content_item_hash = content_item.to_h
        content_item_hash["cache_control"] = {
          "max_age" => content_item.cache_control["max-age"],
          "public" => !content_item.cache_control.private?,
        }
        content_item_hash
      end
    end
  end

  def self.rummager
    GdsApi::Search.new(Plek.find("search-api"))
  end

  def self.search_api_v2
    GdsApi::SearchApiV2.new(Plek.find("search-api-v2"))
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
end
