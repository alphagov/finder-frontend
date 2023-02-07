class FacetTagsPresenter
  def initialize(filters, sort_presenter, i_am_a_topic_page_finder: false)
    @filters = filters
    @sort_option = sort_presenter.selected_option || {}
    @i_am_a_topic_page_finder = i_am_a_topic_page_finder
  end

  def present
    {
      applied_filters: selected_filter_descriptions,
      screen_reader_filter_description: ScreenReaderFilterDescriptionPresenter.new(filters, sort_option).present,
    }
  end

  def selected_filter_descriptions
    selected_filters.map { |filter|
      FacetTagPresenter.new(
        filter.sentence_fragment,
        filter.hide_facet_tag?,
        i_am_a_topic_page_finder:,
      ).present
    }.reject(&:empty?)
  end

  def display_total_selected_filters
    selected_facets_count.zero? ? nil : "(#{selected_facets_count})<span class='govuk-visually-hidden'> filters currently selected</span>"
  end

private

  attr_reader :filters, :sort_option, :i_am_a_topic_page_finder

  def selected_facets_count
    selected_filter_descriptions.flatten.reject { |facet|
      facet[:data_facet] == "keywords"
    }.count
  end

  def selected_filters
    filters.select(&:has_filters?)
  end
end
