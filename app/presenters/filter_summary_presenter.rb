class FilterSummaryPresenter
  def initialize(sort_presenter)
    @sort_presenter = sort_presenter
  end

  def items
    [sort_item].compact
  end

private

  attr_reader :sort_presenter

  def sort_item
    return nil if sort_presenter.default?

    {
      label: "Sort by",
      value: sort_presenter.selected_option_name,
      remove_href: "",
      visually_hidden_prefix: "Remove",
    }
  end
end
