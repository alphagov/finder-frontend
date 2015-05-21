require 'delegate'

class FinderApi
  def initialize(content_store_api:, search_api:)
    @content_store_api = content_store_api
    @search_api = search_api
  end

  def fetch(base_path, params)
    content_item = fetch_content_item(base_path)
    results = fetch_search_results(content_item, params)

    ResultsDecorator.new(
      content_item,
      results,
    )
  end

private
  attr_reader :content_store_api, :search_api

  def fetch_content_item(base_path)
    content_store_api.content_item!(base_path)
  end

  def fetch_search_results(content_item, params)
    # TODO This is very temporary. The necessary functionality in
    # `FinderPresenter` should be extracted and added to `SearchQueryBuilder`
    finder = FinderPresenter.new(content_item, params)
    query = SearchQueryBuilder.new(
      base_filter: finder.filter.to_h,
      metadata_fields: finder.facet_keys,
      default_order: finder.default_order,
      params: finder.search_params,
    ).call

    search_api.unified_search(query).to_hash
  end

  class ResultsDecorator < SimpleDelegator
    attr_reader :results

    def initialize(finder, results)
      super(finder)
      @results = results
    end
  end
end
