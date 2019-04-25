class SortPresenter
  include ActionView::Helpers::FormOptionsHelper

  def initialize(content_item, filter_params)
    @user_selected_order = filter_params['order']
    @keywords = filter_params["keywords"]
    @content_item_sort_options = content_item['details']['sort'] || []
  end

  def has_options?
    content_item_sort_options.any?
  end

  def has_default_option?
    default_option.present?
  end

  def to_hash
    {
      options: options_as_hashes,
      default_value: default_value,
      relevance_value: relevance_value,
    }
  end

  def relevance_value
    option_value(relevance_option)
  end

  def presented_sort_options
    @presented_sort_options ||= content_item_sort_options.map do |option|
      SortOptionPresenter.new(
        label: option['name'],
        key: option['key'],
        default: option['default'],
        selected: option_value(option) == option_value(selected_option),
        disabled: option_value(option) == disabled_option_value,
      )
    end
  end

  def presented_default_option
    presented_sort_options.find(&:default?)
  end

  def default_value
    presented_default_option.try(:value)
  end

  def selected_option
    user_selected_option || default_option
  end

private

  attr_reader :user_selected_order, :keywords, :content_item_sort_options

  RELEVANCE_OPTION_TYPES = %w(relevance -relevance).freeze

  def options_as_hashes
    presented_sort_options.map(&:to_hash)
  end

  def user_selected_option
    content_item_sort_options.find { |option|
      option_value(option) == user_selected_order
    }
  end

  def disabled_option_value
    keywords.blank? && relevance_option.present? ? option_value(relevance_option) : ''
  end

  def default_option
    content_item_sort_options.find { |option| option['default'] }
  end

  def relevance_option
    content_item_sort_options.find { |option|
      RELEVANCE_OPTION_TYPES.include?(option['key'])
    }
  end

  def option_value(option)
    return if option.nil?

    option.fetch('name', '').parameterize
  end
end
