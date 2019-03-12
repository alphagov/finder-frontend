class ScreenReaderFilterDescriptionPresenter
  def initialize(filters, sort_option)
    @filters = filters
    @sort_options = sort_option.present? ? ["sorted by #{sort_option['name']}"] : []
  end

  def present
    text = (facets_without_tags + sort_options).compact.join(", ")
    "<span class='visually-hidden'>#{text}</span>"
  end

private

  attr_reader :filters, :sort_options

  def facets_without_tags
    description = filters.each_with_object([]) do |filter, facets_description|
      if filter.hide_facet_tag?
        filter_label = facet_without_tag_selected_option(filter)

        if filter_label.empty?
          filter_label = facet_without_tag_default_option(filter)
        end

        facets_description << "#{filter.preposition} #{filter_label}" unless filter_label.empty?
      end
    end

    description.compact
  end

  def facet_without_tag_selected_option(filter)
    filter.allowed_values.each do |allowed_value|
      if filter.value == allowed_value['value']
        return allowed_value['label']
      end
    end
    ""
  end

  def facet_without_tag_default_option(filter)
    default_option = filter.allowed_values
                         &.detect { |option| option['default'] }
    return '' if default_option.nil?

    default_option.fetch('label', '')
  end
end
