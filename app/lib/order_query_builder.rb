# typed: true
class OrderQueryBuilder
  def initialize(content_item, keywords, params, override_sort_for_feed: false)
    @content_item = content_item
    @params = params
    @keywords = keywords
    @override_sort_for_feed = override_sort_for_feed
  end

  def call
    return order_by_release_timestamp if sort_option.present? && order_by_release_timestamp?(sort_option)

    return order_by_public_timestamp if override_sort_for_feed
    return order_by_public_timestamp if sort_option.present? && order_by_public_timestamp?(sort_option)

    return order_by_relevance_query if sort_option.present? && order_by_relevance?(sort_option)

    return order_by_sort_option_query if sort_option.present?

    return order_by_relevance_query if keywords.present?

    order_by_default_order_query
  end

private

  attr_reader :content_item, :params, :keywords, :override_sort_for_feed

  def order_by_relevance?(sort_option)
    %w(relevance -relevance topic -topic).include?(sort_option.dig('key'))
  end

  def public_timestamp_unsupported
    params['content_store_document_type'] == 'upcoming_statistics'
  end

  def release_timestamp_unsupported
    %w(published_statistics research).include?(params['content_store_document_type'])
  end

  def order_by_release_timestamp?(sort_option)
    public_timestamp_chosen = %w(-public_timestamp public_timestamp).include?(sort_option.dig('key'))
    public_timestamp_chosen && public_timestamp_unsupported
  end

  def order_by_public_timestamp?(sort_option)
    release_timestamp_chosen = %w(-release_timestamp release_timestamp).include?(sort_option.dig('key'))
    release_timestamp_chosen && release_timestamp_unsupported
  end

  def order_by_public_timestamp
    { 'order' => '-public_timestamp' }
  end

  def order_by_release_timestamp
    { 'order' => '-release_timestamp' }
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
    content_item.dig('details', 'sort')
  end

  def sort_option
    return if sort_options.blank?

    sort_option = if params['order']
                    sort_options.detect { |option| option['name'].parameterize == params['order'] }
                  end

    sort_option || sort_options.detect { |option| option['default'] } || { 'key' => default_order }
  end

  def default_order
    content_item['details']['default_order'] || "-public_timestamp"
  end
end
