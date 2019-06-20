# typed: true
class StatisticsSortPresenter < SortPresenter
  def initialize(content_item, filter_params)
    @stats_grouping = filter_params['content_store_document_type']
    super(content_item, filter_params)
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

  def is_default?(option)
    option['key'] == default_key
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
