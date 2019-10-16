require "spec_helper"

RSpec.describe SpellingSuggestionPresenter do
  describe "#suggestions" do
    it "presents spelling suggestions" do
      suggested_queries = ["full english"]
      url = "/breakfast-finder?keywords=full+english"
      content_item_id = "123AAA"

      presenter = SpellingSuggestionPresenter.new(
        suggested_queries,
        url,
        content_item_id,
      )
      expected = [{ data_attributes: {
          ecommerce_content_id: "123AAA",
          ecommerce_row: 1,
          track_options: {
            dimension81: "full english",
          },
        },
        keywords: "full english",
        link: "/breakfast-finder?keywords=full+english" }]

      expect(presenter.suggestions).to eq(expected)
    end
  end
end
