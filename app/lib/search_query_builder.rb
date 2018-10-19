# SearchQueryBuilder takes the content item for the finder and the query params
# from the URL to generate a query for Rummager.
class SearchQueryBuilder
  def initialize(finder_content_item:, params: {})
    @finder_content_item = finder_content_item
    @params = params
  end

  def call
    [
      pagination_query,
      return_fields_query,
      keyword_query,
      filter_query,
      reject_query,
      order_query,
      facet_query,
    ].reduce(&:merge)
  end

private

  attr_reader :finder_content_item, :params

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
    finder_content_item['details']['default_documents_per_page'] || 1500
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
    finder_content_item['details']['facets'].map { |f| (f['filter_key'] || f['key']) }
  end

  def order_query
    if keywords
      {} # relevance query
    else
      { "order" => params["order"].presence || default_order }
    end
  end

  def keyword_query
    keywords ? { "q" => keywords } : {}
  end

  def keywords
    params["keywords"].presence
  end

  def default_order
    finder_content_item['details']['default_order'] || "-public_timestamp"
  end

  def filter_query
    filter_params
      .merge(base_filter)
      .reduce({}) { |query, (k, v)|
        query.merge("filter_#{k}" => v)
      }
  end

  def reject_query
    base_reject.reduce({}) { |query, (k, v)|
      query.merge("reject_#{k}" => v)
    }
  end

  def filter_params
    @filter_params ||= FilterQueryBuilder.new(
      facets: finder_content_item['details']['facets'],
      user_params: params,
    ).call
  end

  def base_filter
    finder_content_item['details']['filter'].to_h
  end

  def base_reject
    finder_content_item['details']['reject'].to_h
  end

  def facet_query
    facet_params.reduce({}) { |query, (k, v)|
      query.merge("facet_#{k}" => v)
    }
  end

  def facet_params
    @facet_params ||= FacetQueryBuilder.new(
      facets: finder_content_item['details']['facets'],
    ).call
  end
end
