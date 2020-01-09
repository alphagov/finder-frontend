class AutocompleteSuggestionPresenter
  def initialize(autocomplete_results, content_item_id)
    @autocomplete_results = autocomplete_results
    @content_item_id = content_item_id
  end

  def autocompletions
    @autocomplete_results.map
    {
      keywords: autocomplete_results,
      data_attributes:
      {
        ecommerce_content_id: @content_item_id,
        ecommerce_row: 1,
        track_options: {},
      },
    }
  end
end
