# Facade that speaks to Search API. Combines a content item with
# search results from Search API.
module Search
  class Query
    SITE_SEARCH_FINDER_BASE_PATH = "/search/all".freeze

    include ActiveModel::Validations

    attr_reader :filter_params

    validate do |query|
      ParamValidator.new(query).validate
    end

    def initialize(
      content_item,
      filter_params,
      ab_params: {},
      is_for_feed: false,
      v2_serving_config: nil
    )
      @content_item = content_item
      @filter_params = filter_params
      @ab_params = ab_params
      @is_for_feed = is_for_feed
      @order =
        if is_for_feed
          "most-recent"
        else
          filter_params["order"]
        end
      @v2_serving_config = v2_serving_config
    end

    def search_results
      @search_results ||= fetch_search_response(content_item)
    end

    def errors_hash
      ParamValidator.new(self).errors_hash
    end

  private

    attr_reader :ab_params, :is_for_feed, :content_item, :v2_serving_config

    def fetch_search_response(content_item)
      query = QueryBuilder.new(
        finder_content_item: content_item,
        params: filter_params,
        is_for_feed:,
        use_v2_api: use_v2_api?,
        v2_serving_config:,
      ).call

      if use_v2_api?
        Metrics.increment_counter(:searches, api: "v2", finder: content_item.base_path)

        Metrics.observe_duration(:search_request_duration, api: "v2") do
          Services.search_api_v2.search(query).to_hash
        end
      else
        Metrics.increment_counter(:searches, api: "v1", finder: content_item.base_path)

        Metrics.observe_duration(:search_request_duration, api: "v1") do
          Services.rummager.search(query).to_hash
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

      ## Feeds with keywords are sorted newest to oldest, so the relevance benefits of Vertex are
      ## not realised.
      return false if @is_for_feed

      # Use v2 iff the current finder is site search (the only migrated finder so far)
      content_item.base_path == SITE_SEARCH_FINDER_BASE_PATH
    end
  end
end
