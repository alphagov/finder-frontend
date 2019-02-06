# SearchQueryBuilder takes the content item for the finder and the query params
# from the URL to generate a query for Rummager.
class SearchQueryBuilder
  def initialize(finder_content_item:, params: {})
    @finder_content_item = finder_content_item
    @params = params
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
    ].reduce(&:merge)

    return [base_query] if filter_queries.empty?

    filter_queries.map do |query|
      base_query.clone.merge(query)
    end
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
      description_with_highlighting
      public_timestamp
      popularity
    )
  end

  def metadata_fields
    finder_content_item['details']['facets'].map { |f|
      unfilterise(f['filter_key'] || f['key'])
    }
  end

  def unfilterise(field = '')
    # Removes filter-y prefixes from facet keys.
    # For example, filter_x or filter_all_x will become x.
    field.gsub(/^(?'full_name'(?'operation'filter|reject|any|all)_(?:(?'multivalue_query'any|all)_)?(?'name'.*))$/, '\k<name>')
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
    return if sort_options.blank?

    sort_option = if params['order']
                    sort_options.detect { |option| option['name'].parameterize == params['order'] }
                  end

    sort_option || sort_options.detect { |option| option['default'] } || { 'key' => default_order }
  end

  def keyword_query
    keywords ? { "q" => keywords } : {}

    # Temporary fix to remove brexit terms from keyword search
    if keywords
      filtered_keywords = remove_brexit_terms # TODO: Scope this to brexit finder only in future
    end

    keywords ? { "q" => filtered_keywords } : {}
  end

  def remove_brexit_terms
    # Borrowed from Oscar Wyatt's list of stop words in his search prototype PLUS some brexit-y terms
    stop_words = %w(a about above after again against all am an and any are arent as at be
      because been before being below between both but by cant cannot could couldnt
      did didnt do does doesnt doing dont down during each few for from further
      had hadnt has hasnt have havent having he hed hell hes her here heres hers
      herself him himself his how hows i id ill im ive if in into is isnt it
      its its itself lets me more most mustnt my myself no nor not of off on
      once only or other ought our oursourselves out over own same shant she shed
      shell shes should shouldnt so some such than that thats the their theirs them
      themselves then there theres these they theyd theyll theyre theyve this those through
      to too under until up very was wasnt we wed well were weve were werent what
      whats when whens where wheres which while who whos whom why whys with wont would
      wouldnt you youd youll youre youve your yours yourself yourselves brexit eu exit after can i use)

    removed_punctuation = keywords.gsub(/[^a-z0-9\s]/i, '')
    filtered_keywords = ""

    removed_punctuation.downcase.split(" ").each do |word|
      filtered_keywords << word + " " unless stop_words.include?(word)
    end

    filtered_keywords
  end

  def keywords
    params["keywords"].presence
  end

  def default_order
    finder_content_item['details']['default_order'] || "-public_timestamp"
  end

  def base_filter_query
    @base_filter_query ||= base_filter.each_with_object({}) do |(k, v), query|
      query["filter_#{k}"] = v
    end
  end

  def and_filter_query
    @and_filter_query ||= filter_params(combine_mode: 'and')
      .each_with_object({}) do |(k, v), query|
        query["filter_#{k}"] = v
      end
  end

  def or_filter_queries
    @or_filter_queries ||= filter_params(combine_mode: 'or')
      .map do |k, v|
        { "filter_#{k}" => v }
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

  def all_filter_params
    @all_filter_params ||= FilterQueryBuilder.new(
      facets: finder_content_item['details']['facets'],
      user_params: params,
    ).call
  end

  def facet_keys(combine_mode:)
    facets = finder_content_item['details']['facets'].select do |facet|
      facet.fetch('combine_mode', 'and') == combine_mode
    end
    facets.map { |facet| facet['filter_key'] || facet['key'] }
  end

  def filter_params(combine_mode:)
    all_filter_params.slice(*facet_keys(combine_mode: combine_mode))
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
