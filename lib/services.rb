require 'gds_api/content_store'
require 'gds_api/rummager'
require 'gds_api/email_alert_api'

module Services
  def self.cached_content_item(path)
    content_store.cached_content_item(path)
  end

  def self.content_store
    Services::ContentStore.new
  end

  def self.rummager
    GdsApi::Search.new(Plek.find("search"))
  end

  def self.email_alert_api
    Services::EmailAlertApi.new
  end

  def self.worldwide_api
    GdsApi::Worldwide.new(Plek.find('whitehall-admin'))
  end

  def self.registries
    Registries::BaseRegistries.new
  end
end
