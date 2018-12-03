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
    finder_content_item['details']['facets'].map do |f|
      (f['filter_key'] || f['key']).gsub(/^(?'full_name'(?'operation'filter|reject|any|all)_(?:(?'multivalue_query'any|all)_)?(?'name'.*))$/, '\k<name>')
    end
  end

  def order_query
    if sort_option.present?
      if %w(relevance -relevance).include?(sort_option['key'])
        order_by_relevance_query
      else
        order_by_sort_option_query
      end
    elsif keywords.present?
      order_by_relevance_query
    else
      order_by_default_order_query
    end
  end

  def order_by_relevance_query
    {}
  end

  def order_by_default_order_query
    { "order" => default_order }
  end

  def order_by_sort_option_query
    { 'order' => sort_option['key'] }
  end

  def sort_options
    finder_content_item.dig('details', 'sort')
  end

  def sort_option
    return unless sort_options.present?

    sort_option = if params['order']
                    sort_options.detect { |option| option['name'].parameterize == params['order'] }
                  end

    sort_option || sort_options.detect { |option| option['default'] } || { 'key' => default_order }
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
      .merge(base_filter) { |_key, old_value, new_value| [old_value, new_value] }
      .reduce({}) { |query, (k, v)| query.merge("filter_#{k}" => v) }
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
