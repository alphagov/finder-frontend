class FiltersPresenter
  def initialize(facets, finder_url_builder)
    @facets = facets
    @finder_url_builder = finder_url_builder
  end

  def any_filters?
    facets.any?(&:has_filters?)
  end

  def summary_items
    facets.flat_map(&:applied_filters).map do |filter|
      {
        label: filter[:name],
        value: filter[:label],
        remove_href: "#",
        visually_hidden_prefix: "Remove filter",
      }
    end
  end

  def reset_url
    "#"
  end

private

  attr_reader :facets, :finder_url_builder
end
