class SpellingSuggestionPresenter
  def initialize(suggested_queries, url, content_item_id)
    @suggested_queries = suggested_queries
    @url = url
    @content_item_id = content_item_id
  end

  def suggestions
    @suggested_queries.map do |suggestion|
      {
        keywords: suggestion["text"],
        highlighted: suggestion["highlighted"],
        link: @url,
        data_attributes: {
          ecommerce_content_id: @content_item_id,
          ecommerce_row: 1,
          track_options: {
            dimension81: suggestion["text"],
          },
        },
      }
    end
  end
end
