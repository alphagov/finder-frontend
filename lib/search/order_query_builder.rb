module Search
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
      %w(relevance -relevance topic -topic).include?(sort_option.dig("key"))
    end

    def public_timestamp_unsupported
      %w(upcoming_statistics cancelled_statistics).include?(params["content_store_document_type"])
    end

    def release_timestamp_unsupported
      %w(published_statistics research).include?(params["content_store_document_type"])
    end

    def order_by_release_timestamp?(sort_option)
      public_timestamp_chosen = %w(-public_timestamp public_timestamp).include?(sort_option.dig("key"))
      public_timestamp_chosen && public_timestamp_unsupported
    end

    def order_by_public_timestamp?(sort_option)
      release_timestamp_chosen = %w(-release_timestamp release_timestamp).include?(sort_option.dig("key"))
      release_timestamp_chosen && release_timestamp_unsupported
    end

    def order_by_public_timestamp
      { "order" => "-public_timestamp" }
    end

    def order_by_release_timestamp
      { "order" => "-release_timestamp" }
    end

    def order_by_relevance_query
      {}
    end

    def order_by_default_order_query
      { "order" => default_order }
    end

    def order_by_sort_option_query
      { "order" => sort_option["key"] }
    end

    def order_presenter
      @order_presenter ||= content_item.sorter_class.new(content_item, params)
    end

    def sort_option
      return if order_presenter.sort_options.blank?

      order_presenter.selected_option
    end

    def default_order
      if order_presenter.default_option
        order_presenter.default_option["key"]
      else
        content_item.default_order
      end
    end
  end
end
