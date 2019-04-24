class SortPresenter
  include ActionView::Helpers::FormOptionsHelper

  def initialize(content_item, filter_params)
    @user_selected_order = filter_params['order']
    @keywords = filter_params["keywords"]
    @sort_options = (content_item['details']['sort'] || []).map do |option|
      SortOptionPresenter.new(
        label: option['name'],
        key: option['key'],
        default: option['default']
      )
    end
  end

  def has_options?
    sort_options.any?
  end

  def has_default_option?
    default_option.present?
  end

  def for_select
    options_for_select(all_options, selected: selected_option, disabled: disabled_option)
  end

  def default_option
    sort_options.find(&:default?)
  end

  def default_value
    default_option.try(:value)
  end

  def relevance_value
    relevance_option.try(:value)
  end

  def find_by_value(value)
    sort_options.find { |option| option.value == value }
  end

private

  attr_reader :sort_options, :user_selected_order, :keywords

  def all_options
    sort_options.collect { |option| option.to_select_format }
  end

  def selected_option
    has_select_valid_option? ? user_selected_order : default_option.try(:value)
  end

  def has_select_valid_option?
    sort_options.any? { |option| option.value == user_selected_order }
  end

  def disabled_option
    keywords.blank? ? relevance_option.try(:value) : ''
  end

  def relevance_option
    sort_options.find(&:relevance?)
  end
end
