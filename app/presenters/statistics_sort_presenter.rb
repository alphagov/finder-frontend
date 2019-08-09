class StatisticsSortPresenter < SortPresenter
  def initialize(content_item, filter_params)
    @doc_type = filter_params['content_store_document_type']
    super(content_item, filter_params)
  end

private

  attr_reader :doc_type, :user_selected_order, :keywords, :content_item_sort_options

  RELEVANCE_OPTION_TYPES = %w(relevance -relevance).freeze
  EXCLUDED_OPTIONS = {
    any: [],
    public: %w(-release_timestamp release_timestamp),
    release: %w(-public_timestamp public_timestamp)
  }.freeze
  DEFAULT_KEY = {
    any: '-public_timestamp',
    public: '-public_timestamp',
    release: '-release_timestamp'
  }.freeze

  def default_key
    DEFAULT_KEY[sort_type]
  end

  def is_default?(option)
    option['key'] == default_key
  end

  def sort_options
    content_item_sort_options.reject { |option|
      EXCLUDED_OPTIONS[sort_type].include? option['key']
    }
  end

  def raw_default_option
    sort_options.find { |option| option['key'] == default_key }
  end

  def sort_type
    case doc_type
    when 'upcoming_statistics'
      :release
    when 'published_statistics'
      :public
    when 'cancelled_statistics'
      :any
    else
      :public
    end
  end
end
