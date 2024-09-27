class FiltersPresenter
  def initialize(facets, finder_url_builder)
    @facets = facets
    @finder_url_builder = finder_url_builder
  end

  def any_filters?
    false
  end

  def summary_items
    []
  end

  def reset_url
    "#"
  end

private

  attr_reader :facets, :finder_url_builder
end
