# Search::QueryBuilder takes the content item for the finder and the query params
# from the URL to generate a query for Search API.
module Search
  class QueryBuilder
    # search-api rejects queries which are longer than this, but an
    # error page isn't a good experience for users.  There are some
    # legitimate queries over this length (people typing a length
    # question into the search box), so rather than give them an error
    # page just give them (probably unhelpful) results.  At some point
    # we shall do UI work to direct people who enter a long query to the
    # contact form, as even an untruncated long query isn't going to
    # find anything useful, too much noise.
    MAX_QUERY_LENGTH = 512

    LICENCE_STOPWORDS = %w[licence license permit certification].freeze

    def initialize(
      finder_content_item:,
      params: {},
      ab_params: {},
      is_for_feed: false,
      use_v2_api: false,
      v2_serving_config: nil
    )
      @finder_content_item = finder_content_item
      @params = params
      @ab_params = ab_params
      @is_for_feed = is_for_feed
      @use_v2_api = use_v2_api
      @v2_serving_config = v2_serving_config
    end

    def call
      [
        pagination_query,
        return_fields_query,
        keyword_query,
        base_filter_query,
        facet_filter_query,
        reject_query,
        order_query,
        facet_query,
        v2_serving_config_query,
        debug_query,
        ab_query,
        suggest_query,
        boost_fields_query,
      ].reduce(&:merge)
    end

  private

    attr_reader :finder_content_item, :params, :ab_params, :is_for_feed,
                :v2_serving_config

    def use_v2_api?
      @use_v2_api
    end

    def pagination_query
      {
        "count" => documents_per_page,
        "start" => pagination_start,
      }
    end

    def pagination_start
      documents_per_page * (current_page - 1) || 0
    end

    def current_page
      [params["page"].to_i, 1].max
    rescue StandardError
      1
    end

    def documents_per_page
      finder_content_item.default_documents_per_page
    end

    def return_fields_query
      {
        "fields" => return_fields.join(","),
      }
    end

    def return_fields
      (base_return_fields + metadata_fields).uniq
    end

    def base_return_fields
      %w[
        title
        link
        description_with_highlighting
        public_timestamp
        popularity
        content_purpose_supergroup
        content_store_document_type
        format
        is_historic
        government_name
        content_id
        parts
      ]
    end

    def metadata_fields
      raw_facets.map { |f|
        if f["sub_facet_key"]
          [unfilterise(f["filter_key"] || f["key"]), unfilterise(f["sub_facet_key"])]
        else
          unfilterise(f["filter_key"] || f["key"])
        end
      }.flatten
    end

    def raw_facets
      finder_content_item.raw_facets
    end

    def unfilterise(field = "")
      # Removes filter-y prefixes from facet keys.
      # For example, filter_x or filter_all_x will become x.
      field.gsub(/^(?'full_name'(?'operation'filter|reject|any|all)_(?:(?'multivalue_query'any|all)_)?(?'name'.*))$/, '\k<name>')
    end

    def order_query
      OrderQueryBuilder.new(
        finder_content_item,
        keywords,
        params,
        is_for_feed:,
      ).call
    end

    def keyword_query
      keywords ? { "q" => keywords[0, MAX_QUERY_LENGTH] } : {}
    end

    def keywords
      return remove_stopwords if remove_stopwords?

      params["keywords"].presence
    end

    def remove_stopwords?
      params["keywords"].present? && stopwords_for_path.any?
    end

    def stopwords_for_path
      finder_content_item.is_licence_transaction? ? LICENCE_STOPWORDS : []
    end

    def remove_stopwords
      keywords = params["keywords"].split(" ")
      keywords.delete_if do |keyword|
        stopwords_for_path.include?(keyword.downcase.gsub(/\W/, ""))
      end
      keywords.join(" ")
    end

    def facet_filter_query
      @facet_filter_query ||= facet_filter_params.transform_keys do |k|
        "filter_#{k}"
      end
    end

    def base_filter_query
      @base_filter_query ||= base_filter.transform_keys do |k|
        "filter_#{k}"
      end
    end

    def reject_query
      base_reject.reduce({}) do |query, (k, v)|
        query.merge("reject_#{k}" => v)
      end
    end

    def facet_filter_params
      @facet_filter_params ||= FilterQueryBuilder.new(
        facets: raw_facets,
        user_params: params,
      ).call
    end

    def base_filter
      finder_content_item.filter
    end

    def base_reject
      finder_content_item.reject
    end

    def facet_query
      dynamic_facet_params = facets_not_overridden_by_registries(facet_params)
      count_dynamic_facets(dynamic_facet_params.keys)

      dynamic_facet_params.reduce({}) { |query, (k, v)| query.merge("facet_#{k}" => v) }
    end

    def facets_not_overridden_by_registries(facet_params)
      facet_params.reject { |k, _v| Services.registries.all.key?(k) }
    end

    def count_dynamic_facets(facet_names)
      facet_names.each do |name|
        GovukStatsd.increment "search_with_#{name}_facet"
      end
    end

    def facet_params
      @facet_params ||= FacetQueryBuilder.new(
        facets: raw_facets,
      ).call
    end

    def v2_serving_config_query
      return {} unless use_v2_api?

      {
        "serving_config" => v2_serving_config,
      }.compact
    end

    def debug_query
      if use_v2_api?
        {
          "serving_config" => params["debug_serving_config"],
        }.compact
      else
        {
          "debug" => params["debug"],
        }.compact
      end
    end

    def ab_query
      ab_params.any? ? { "ab_tests" => ab_params.map { |k, v| "#{k}:#{v}" }.join(",") } : {}
    end

    def suggest_query
      { "suggest" => "spelling_with_highlighting" }
    end

    def boost_fields_query
      return {} unless finder_content_item.is_licence_transaction?

      { "boost_fields" => "licence_transaction_industry" }
    end

    def force_ltr?
      params["force-ltr"] == "true"
    end
  end
end
