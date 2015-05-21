require 'gds_api/rummager'

module FinderFrontend
  def self.get_documents(finder, params)
    query = SearchQueryBuilder.new(
      base_filter: finder.filter.to_h,
      metadata_fields: finder.facet_keys,
      default_order: finder.default_order,
      params: params,
    ).call

    rummager_api.unified_search(query).to_hash
  end

  def self.rummager_api
    GdsApi::Rummager.new(Plek.find("search"))
  end
end
