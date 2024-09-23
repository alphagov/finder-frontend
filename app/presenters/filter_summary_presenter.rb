class FilterSummaryPresenter
  def initialize(sort_presenter, finder_url_builder)
    @sort_presenter = sort_presenter
    @finder_url_builder = finder_url_builder
  end

  def items
    [sort_item].compact
  end

  def clear_all_href
    finder_url_builder.url_except_params(:order)
  end

private

  attr_reader :sort_presenter, :finder_url_builder

  def sort_item
    return nil if sort_presenter.default?

    {
      label: "Sort by",
      value: sort_presenter.selected_option_name,
      remove_href: finder_url_builder.url_except_params(:order),
      visually_hidden_prefix: "Remove",
    }
  end
end
