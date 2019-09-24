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

    def initialize(finder_content_item:, params: {}, ab_params: {}, override_sort_for_feed: false)
      @finder_content_item = finder_content_item
      @params = params
      @ab_params = ab_params
      @override_sort_for_feed = override_sort_for_feed
    end

    def call
      base_query = [
        pagination_query,
        return_fields_query,
        keyword_query,
        base_filter_query,
        reject_query,
        order_query,
        facet_query,
        debug_query,
        ab_query,
        suggest_query,
      ].reduce(&:merge)

      return [base_query] if filter_queries.empty?

      filter_queries.map do |query|
        base_query.clone.merge(query)
      end
    end

  private

    attr_reader :finder_content_item, :params, :ab_params, :override_sort_for_feed


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
      %w(
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
      )
    end

    def metadata_fields
      raw_facets.map { |f|
        unfilterise(f["filter_key"] || f["key"])
      }
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
        override_sort_for_feed: override_sort_for_feed,
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
      params["keywords"].present? && ["/find-eu-exit-guidance-business"].include?(finder_content_item.base_path)
    end

    def remove_stopwords
      keywords = params["keywords"].split(" ")
      keywords.delete_if do |keyword|
        stopwords.include?(keyword.downcase.gsub(/\W/, ""))
      end
      keywords.join(" ")
    end

    def base_filter_query
      @base_filter_query ||= base_filter.each_with_object({}) do |(k, v), query|
        query["filter_#{k}"] = v
      end
    end

    def and_filter_query
      @and_filter_query ||= and_filter_params
        .each_with_object({}) do |(k, v), query|
          query["filter_#{k}"] = v
        end
    end

    def and_filter_params
      @and_filter_params ||= FilterQueryBuilder.new(
        facets: and_facets,
        user_params: params,
      ).call
    end

    def and_facets
      raw_facets.select do |facet|
        facet.fetch("combine_mode", "and") == "and"
      end
    end

    def or_filter_queries
      @or_filter_queries ||= or_filter_params
        .map do |k, v|
          { "filter_#{k}" => v }
        end
    end

    def or_filter_params
      @or_filter_params ||= FilterQueryBuilder.new(
        facets: or_facets,
        user_params: params,
      ).call
    end

    def or_facets
      raw_facets.select do |facet|
        facet.fetch("combine_mode", "and") == "or"
      end
    end

    def filter_queries
      (and_filter_query.empty? ? [] : [and_filter_query]) + or_filter_queries
    end

    def reject_query
      base_reject.reduce({}) { |query, (k, v)|
        query.merge("reject_#{k}" => v)
      }
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
      facet_params.reject { |k, _v| Services.registries.all.has_key?(k) }
    end

    def count_dynamic_facets(facet_names)
      facet_names.each { |name|
        GovukStatsd.increment "search_with_#{name}_facet"
      }
    end

    def facet_params
      @facet_params ||= FacetQueryBuilder.new(
        facets: raw_facets,
      ).call
    end

    def debug_query
      {
        "debug" => params["debug"],
      }.compact
    end

    def ab_query
      ab_params.any? ? { "ab_tests" => ab_params.map { |k, v| "#{k}:#{v}" }.join(",") } : {}
    end

    def suggest_query
      { "suggest" => "spelling" }
    end

    def stopwords
      generic_stopwords = %w(
       a about above after again against all am an and any are arent as at
       be because been before being below between both but by
       cant cannot could couldnt
       did didnt do does doesnt doing dont down during
       each
       few for from further
       had hadnt has hasnt have havent having he hed hell hes her here heres hers herself him himself his how hows
       i id ill im ive if in into is isnt it its itself
       lets
       me more most mustnt my myself
       no nor not of off on once only or other ought our ours ourselves out over own
       same shant she shed shell shes should shouldnt so some such
       than that thats the their theirs them themselves then there theres these they theyd theyll theyre theyve this those through to too
       under until up
       very
       was wasnt we wed well were werent weve what whats when whens where wheres which while who whos whom why whys with wont would wouldnt
       you youd youll youre youve your yours yourself yourselves
      )

      brexit_stopwords = %w(abroad brexit eu europe european exit leave union)

      (generic_stopwords + brexit_stopwords).uniq
    end
  end
end
