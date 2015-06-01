require 'delegate'

class FinderApi
  def initialize(content_api:, search_api:)
    @content_api = content_api
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
  attr_reader :content_api, :search_api

  def fetch_content_item(base_path)
    content_api.content_item!(base_path)
  end

  def fetch_search_results(content_item, params)
    query = SearchQueryBuilder.new(
      finder_content_item: content_item,
      params: params,
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
