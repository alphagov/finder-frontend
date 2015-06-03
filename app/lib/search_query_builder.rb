class SearchQueryBuilder
  def initialize(filter_query_builder:, finder_content_item:, params: {})
    @filter_query_builder = filter_query_builder
    @finder_content_item = finder_content_item
    @params = params
  end

  def call
    [
      base_query,
      return_fields_query,
      keyword_query,
      filter_query,
      order_query,
    ].reduce(&:merge)
  end

private
  attr_reader :filter_query_builder, :finder_content_item, :params
  
  def base_query
    {
      "count" => "1000",
    }
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
      description
      public_timestamp
    )
  end

  def metadata_fields
    finder_content_item.details.facets.map(&:key)
  end

  def order_query
    keywords ? order_by_relevance_query : default_order_query
  end

  def order_by_relevance_query
    {}
  end

  def default_order_query
    {"order" => default_order}
  end

  def keyword_query
    keywords ? {"q" => keywords} : {}
  end

  def keywords
    params["keywords"].presence
  end

  def default_order
    finder_content_item.details.default_order || "-public_timestamp"
  end

  def filter_query
    filter_params
      .merge(base_filter)
      .reduce({}) { |query, (k, v)|
        query.merge("filter_#{k}" => v)
      }
  end

  def filter_params
    @filter_params ||= filter_query_builder.call(
      facets: finder_content_item.details.facets,
      user_params: params,
    )
  end

  def base_filter
    finder_content_item.details.filter.to_h
  end
end
