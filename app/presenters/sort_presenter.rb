class SortPresenter
  def initialize(content_item, filter_params)
    @user_selected_order = filter_params['order']
    @keywords = filter_params["keywords"]
    @content_item_sort_options = content_item.sort_options
  end

  def to_hash
    return nil unless has_options?

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

  def sort_options
    content_item_sort_options
  end

private

  attr_reader :user_selected_order, :keywords, :content_item_sort_options

  RELEVANCE_OPTION_TYPES = %w(relevance -relevance).freeze

  def has_options?
    content_item_sort_options.any?
  end

  def presented_sort_options
    @presented_sort_options ||= sort_options.map do |option|
      SortOptionPresenter.new(
        label: option['name'],
        value: option_value(option),
        key: option['key'],
        default: is_default?(option),
        selected: option_value(option) == option_value(selected_option),
        disabled: option_value(option) == disabled_option_value,
      )
    end
  end

  def is_default?(option)
    option['default']
  end

  def options_as_hashes
    presented_sort_options.map(&:to_hash)
  end

  def user_selected_option
    sort_options.find { |option| option_value(option) == user_selected_order }
  end

  def disabled_option_value
    keywords.blank? && relevance_option.present? ? option_value(relevance_option) : ''
  end

  def raw_default_option
    sort_options.find { |option| option['default'] }
  end

  def relevance_option
    sort_options.find { |option| RELEVANCE_OPTION_TYPES.include?(option['key']) }
  end

  def option_value(option)
    return if option.nil?

    option.fetch('value', option.fetch('name', '').parameterize)
  end
end
