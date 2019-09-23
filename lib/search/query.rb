# Facade that speaks to rummager. Combines a content item with
# search results from rummager.
module Search
  class Query
    def initialize(content_item, filter_params, ab_params: {}, override_sort_for_feed: false)
      @content_item = content_item
      @filter_params = filter_params
      @ab_params = ab_params
      @override_sort_for_feed = override_sort_for_feed
      @order =
        if override_sort_for_feed
          "most-recent"
        else
          filter_params["order"]
        end
    end

    def search_results
      @search_results ||= fetch_search_response(content_item)
    end

  private

    attr_reader :ab_params, :filter_params, :override_sort_for_feed, :content_item

    def merge_and_deduplicate(search_response)
      results = search_response.fetch("results")

      return results[0] if results.count == 1

      # This currently doesn't handle more complex features such as pagination.
      # The only finder where the facets work as an OR filter
      # doesn't use pagination and there aren't enough documents it to be
      # important. The results are sorted here because they are only
      # sorted by Rummager within the results of each query.

      all_unique_results = results
        .flat_map { |hash| hash["results"] }
        .uniq { |hash| hash["_id"] }
      {
        "results" => sort_batch_results(all_unique_results),
        "total" => all_unique_results.count,
        "start" => 0,
      }
    end

    def sort_batch_results(raw_results)
      case @order
      when "most-viewed"
        raw_results.sort_by { |hash| hash["popularity"] }.reverse
      when "most-recent"
        raw_results.sort_by { |hash| hash["public_timestamp"] }.reverse
      when "a-to-z"
        raw_results.sort_by { |hash| hash["title"] }
      else
        sort_by_relevance(raw_results)
      end
    end

    def sort_by_relevance(raw_results)
      return raw_results unless relevance_scores_exist?(raw_results)

      raw_results.sort_by { |hash| hash["es_score"] }.reverse
    end

    def relevance_scores_exist?(results)
      results.all? { |result| result["es_score"].present? }
    end

    def fetch_search_response(content_item)
      queries = QueryBuilder.new(
        finder_content_item: content_item,
        params: filter_params,
        ab_params: ab_params,
        override_sort_for_feed: override_sort_for_feed,
      ).call

      if queries.one?
        GovukStatsd.time("rummager.finder_search") do
          Services.rummager.search(queries.first).to_hash
        end
      else
        GovukStatsd.time("rummager.finder_batch_search") do
          merge_and_deduplicate(
            Services.rummager.batch_search(queries).to_hash,
          )
        end
      end
    end
  end
end
