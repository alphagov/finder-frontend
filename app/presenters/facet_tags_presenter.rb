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
        i_am_a_topic_page_finder: i_am_a_topic_page_finder,
      ).present
    }.reject(&:empty?)
  end

private

  attr_reader :filters, :sort_option, :i_am_a_topic_page_finder

  def selected_filters
    filters.select(&:has_filters?)
  end
end
