class FiltersPresenter
  def initialize(facets, finder_url_builder)
    @facets = facets
    @finder_url_builder = finder_url_builder
  end

  def any_filters?
    applied_filters.any?
  end

  def summary_items
    applied_filters.map do |filter|
      {
        label: filter[:name],
        value: filter[:label],
        displayed_text: "#{filter[:name]}: #{filter[:label]}",
        remove_href: finder_url_builder.url_except(filter[:query_params]),
        visually_hidden_prefix: "Remove filter",
      }
    end
  end

  def reset_url
    return unless any_filters?

    finder_url_builder.url_except_keys(all_filter_keys)
  end

private

  attr_reader :facets, :finder_url_builder

  def applied_filters
    @applied_filters ||= facets.flat_map(&:applied_filters)
  end

  def all_filter_keys
    applied_filters
      .flat_map { |filter| filter[:query_params].keys }
      .uniq
  end
end
