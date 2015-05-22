class SearchQueryBuilder
  def initialize(finder_content_item:, params: {})
    @finder_content_item = finder_content_item
    @params = params
  end

  def call
    default_params.merge(massaged_params)
  end

private
  attr_reader :finder_content_item, :params
  
  def default_params
    {
      "count"  => "1000",
      "fields" => return_fields.join(","),
    }
  end

  def return_fields
    base_return_fields.concat(metadata_fields).uniq
  end

  def base_return_fields
    %w(
      title
      link
      description
      public_timestamp
    )
  end

  def facets
    @facets ||= FacetCollection.new(
      finder_content_item.details.facets.map { |facet|
        FacetParser.parse(facet)
      }
    ).tap { |collection| collection.values = params }
  end

  def metadata_fields
    facets.to_a.map(&:key)
  end

  def massaged_params
    keyword_param
      .merge(filter_params)
      .merge(order_param)
  end

  def keywords
    params["keywords"].presence
  end

  def keyword_param
    if keywords
      {"q" => keywords}
    else
      {}
    end
  end

  def order_param
    if keywords
      {}
    else
      {"order" => default_order}
    end
  end

  def default_order
    finder_content_item.details.default_order || "-public_timestamp"
  end

  def filter_params
    facets
      .values
      .merge(base_filter)
      .reduce({}) { |memo, (k,v)|
        memo.merge("filter_#{k}" => v)
      }
  end

  def base_filter
    finder_content_item.details.filter.to_h
  end
end
