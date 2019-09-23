class ScreenReaderFilterDescriptionPresenter
  def initialize(filters, sort_option)
    @filters = filters
    @sort_options = sort_option.present? ? ["sorted by #{sort_option['name']}"] : []
  end

  def present
    (facets_without_tags + sort_options).join(", ")
  end

private

  attr_reader :filters, :sort_options

  def facets_without_tags
    description = filters.select(&:hide_facet_tag?).each_with_object([]) do |filter, facets_description|
      label = filter_label(filter)
      facets_description << "#{filter.preposition} #{label}" unless label.nil?
    end

    description.compact
  end

  def filter_label(filter)
    selected_option = filter.allowed_values.find { |option| option["value"] == filter.value }
    return selected_option["label"] unless selected_option.nil?

    default_option = filter.allowed_values.find { |option| option["default"] }
    return default_option["label"] unless default_option.nil?

    nil
  end
end
