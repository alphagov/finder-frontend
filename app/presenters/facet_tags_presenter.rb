class FacetTagsPresenter
  def initialize(finder_presenter, sort_presenter)
    @filters = finder_presenter.filters
    @keywords = finder_presenter.keywords
    @sort_option = sort_presenter.selected_option || {}
  end

  def present
    {
      applied_filters: selected_filter_descriptions,
      screen_reader_filter_description: ScreenReaderFilterDescriptionPresenter.new(filters, sort_option).present
    }
  end

  def selected_filter_descriptions
    selected_filters.map { |filter|
      FacetTagPresenter.new(filter.sentence_fragment, filter.hide_facet_tag?).present
    }.reject(&:empty?)
  end

private

  attr_reader :filters, :sort_option, :keywords

  def selected_filters
    (filters + [KeywordFacet.new(keywords)]).select(&:has_filters?)
  end
end
