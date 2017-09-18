# Facade that speaks to the content store and rummager. Returns a content
# item for the finder combined with the actual search results from rummager.
class FinderApi
  def initialize(base_path, filter_params)
    @base_path = base_path
    @filter_params = filter_params
  end

  def content_item_with_search_results
    content_item = fetch_content_item
    search_response = fetch_search_response(content_item)

    augment_content_item_with_results(
      content_item,
      search_response,
    )
  end

private

  attr_reader :base_path, :filter_params

  def fetch_content_item
    Services.content_store.content_item(base_path).to_ostruct
  end

  def fetch_search_response(content_item)
    query = SearchQueryBuilder.new(
      finder_content_item: content_item,
      params: filter_params,
    ).call

    Services.rummager.search(query).to_hash
  end

  def augment_content_item_with_results(content_item, search_response)
    content_item.details.results = search_response.fetch("results")
    content_item.details.total_result_count = search_response.fetch("total")

    content_item.details.pagination = build_pagination(
      content_item.details.default_documents_per_page,
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
    if documents_per_page
      OpenStruct.new(
        current_page: (start_offset / documents_per_page) + 1,
        total_pages: (total_results / documents_per_page.to_f).ceil,
      )
    end
  end
end
