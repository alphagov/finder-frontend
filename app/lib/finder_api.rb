require 'delegate'

class FinderApi
  def initialize(content_store_api:, search_api:)
    @content_store_api = content_store_api
    @search_api = search_api
  end

  def fetch(base_path, params)
    content_item = fetch_content_item(base_path)
    search_response = fetch_search_response(content_item, params)

    augment_content_item_with_results(
      content_item,
      search_response,
    )
  end

private
  attr_reader :content_store_api, :search_api

  def fetch_content_item(base_path)
    content_store_api.content_item!(base_path)
  end

  def fetch_search_response(content_item, params)
    query = SearchQueryBuilder.new(
      filter_query_builder: filter_query_builder,
      facet_query_builder: facet_query_builder,
      finder_content_item: content_item,
      params: params,
    ).call

    search_api.unified_search(query).to_hash
  end

  def filter_query_builder
    ->(**args) { FilterQueryBuilder.new(args).call }
  end

  def facet_query_builder
    ->(**args) { FacetQueryBuilder.new(args).call }
  end

  def augment_content_item_with_results(content_item, search_response)
    content_item.details.results = search_response.fetch("results")
    content_item.details.total_result_count = search_response.fetch("total")

    content_item.details.pagination = build_pagination(
      content_item.details.documents_per_page,
      search_response.fetch('start'),
      search_response.fetch('total')
    )

    search_response.fetch("facets", {}).each do |facet_key, facet_details|
      facet = content_item.details.facets.find { |f| f.key == facet_key }
      facet.allowed_values = allowed_values_for_facet_details(facet_details) if facet
    end

    content_item
  end

  def allowed_values_for_facet_details(facet_details)
    values = facet_details.fetch("options", {}).map { |f| f.fetch("value", {}) }

    values.map { |value|
      OpenStruct.new(
        label: value.fetch("title", ""),
        value: value.fetch("slug", ""),
      )
    }
  end

  def build_pagination(documents_per_page, start_offset, total_results)
    OpenStruct.new(
      current_page: (start_offset / documents_per_page) + 1,
      total_pages: (total_results / documents_per_page.to_f).ceil,
    ) if documents_per_page
  end
end
