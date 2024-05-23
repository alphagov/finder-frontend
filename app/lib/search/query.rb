# Facade that speaks to rummager. Combines a content item with
# search results from rummager.
module Search
  class Query
    SITE_SEARCH_FINDER_BASE_PATH = "/search/all".freeze

    include ActiveModel::Validations

    attr_reader :filter_params

    validate do |query|
      ParamValidator.new(query).validate
    end

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

    def errors_hash
      ParamValidator.new(self).errors_hash
    end

  private

    attr_reader :ab_params, :override_sort_for_feed, :content_item

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

      raw_results.sort_by { |hash| hash["combined_score"] || hash["es_score"] }.reverse
    end

    def relevance_scores_exist?(results)
      results.all? { |result| (result["combined_score"] || result["es_score"]).present? }
    end

    def fetch_search_response(content_item)
      queries = QueryBuilder.new(
        finder_content_item: content_item,
        params: filter_params,
        override_sort_for_feed:,
      ).call

      if use_v2_api?
        Metrics.increment_counter(:searches, api: "v2", finder: content_item.base_path)

        Metrics.observe_duration(:search_request_duration, api: "v2") do
          Services.search_api_v2.search(queries.first).to_hash
        end
      elsif queries.one?
        Metrics.increment_counter(:searches, api: "v1", finder: content_item.base_path)

        Metrics.observe_duration(:search_request_duration, api: "v1") do
          Services.rummager.search(queries.first).to_hash
        end
      else
        Metrics.increment_counter(:searches, api: "v1_bulk", finder: content_item.base_path)

        Metrics.observe_duration(:search_request_duration, api: "v1_bulk") do
          merge_and_deduplicate(
            Services.rummager.batch_search(queries).to_hash,
          )
        end
      end
    end

    def use_v2_api?
      # Query params to force the use of v1 or v2 should take precedence over any other logic
      return false if ActiveModel::Type::Boolean.new.cast(filter_params["use_v1"])
      return true if ActiveModel::Type::Boolean.new.cast(filter_params["use_v2"])

      # Feature flag to allow fallback to v1 as a backup in case of major issues with v2
      return false if ActiveModel::Type::Boolean.new.cast(ENV["FORCE_USE_V1_SEARCH_API"])

      # Use v1 in scenarios where v2 is not (yet) able to give us good results
      # These scenarios should be reviewed as we continue our migration work and Vertex AI Search
      # evolves.
      ## Whitehall directly indexes slugs for world locations into v1, which we don't have access
      ## to in v2, breaking world location facets.
      return false if filter_params["world_locations"].present?
      ## Vertex AI Search is not designed to handle non-keyword queries well, and there are cost
      ## implications as well when it comes to bot traffic.
      return false if filter_params["keywords"].blank?

      # Use v2 iff the current finder is site search (the only migrated finder so far)
      content_item.base_path == SITE_SEARCH_FINDER_BASE_PATH
    end
  end
end
