require 'gds_api/content_store'
require 'gds_api/rummager'

module FinderFrontend
  def self.finder_api
    FinderApi.new(
      content_store_api: content_store_api,
      search_api: rummager_api,
    )
  end

  def self.content_store_api
    GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def self.rummager_api
    GdsApi::Rummager.new(Plek.find("search"))
  end
end
