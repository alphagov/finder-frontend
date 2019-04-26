class StatisticsSortPresenter < BaseSortPresenter
  def initialize(content_item, filter_params)
    @stats_grouping = filter_params['content_store_document_type']
    @user_selected_order = filter_params['order']
    @keywords = filter_params["keywords"]
    @content_item_sort_options = content_item['details']['sort'] || []
  end

  def has_options?
    content_item_sort_options.any?
  end

  def to_hash
    {
      options: options_as_hashes,
      default_value: default_value,
      relevance_value: option_value(relevance_option),
    }
  end

  def default_option
    presented_sort_options.find(&:default?)
  end

  def default_value
    default_option.try(:value)
  end

  def selected_option
    user_selected_option || raw_default_option
  end

private

  attr_reader :stats_grouping, :user_selected_order, :keywords, :content_item_sort_options

  RELEVANCE_OPTION_TYPES = %w(relevance -relevance).freeze
  EXCLUDED_OPTIONS = {
    published: %w(-release_timestamp release_timestamp),
    upcoming: %w(-public_timestamp public_timestamp),
  }.freeze
  DEFAULT_KEY = {
    published: '-public_timestamp',
    upcoming: '-release_timestamp',
  }.freeze

  def default_key
    DEFAULT_KEY[group]
  end

  def presented_sort_options
    @presented_sort_options ||= sort_options.map do |option|
      SortOptionPresenter.new(
        label: option['name'],
        key: option['key'],
        default: option['key'] == default_key,
        selected: option_value(option) == option_value(selected_option),
        disabled: option_value(option) == disabled_option_value,
      )
    end
  end

  def options_as_hashes
    presented_sort_options.map(&:to_hash)
  end

  def user_selected_option
    sort_options.find { |option| option_value(option) == user_selected_order }
  end

  def disabled_option_value
    option_value(relevance_option) if keywords.blank? && relevance_option.present?
  end

  def relevance_option
    sort_options.find { |option| RELEVANCE_OPTION_TYPES.include?(option['key']) }
  end

  def option_value(option)
    return if option.nil?

    option.fetch('name', '').parameterize
  end

  def sort_options
    content_item_sort_options.reject { |option|
      EXCLUDED_OPTIONS[group].include? option['key']
    }
  end

  def raw_default_option
    sort_options.find { |option| option['key'] == default_key }
  end

  def group
    stats_grouping == 'upcoming_statistics' ? :upcoming : :published
  end
end
