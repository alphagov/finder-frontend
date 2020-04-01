class SpellingSuggestionPresenter
  def initialize(suggested_queries, url, content_item_path)
    @suggested_queries = suggested_queries
    @url = url
    @content_item_path = content_item_path
  end

  def suggestions
    @suggested_queries.map do |suggestion|
      {
        keywords: suggestion["text"],
        highlighted: suggestion["highlighted"],
        link: @url,
        data_attributes: {
          ecommerce_path: @content_item_path,
          ecommerce_row: 1,
          track_options: {
            dimension81: suggestion["text"],
          },
        },
      }
    end
  end
end
