require "spec_helper"

RSpec.describe SpellingSuggestionPresenter do
  describe "#suggestions" do
    it "presents spelling suggestions" do
      suggested_queries = [{ "text" => "full english", "highlighted" => "<mark>full</mark> english" }]
      url = "/breakfast-finder?keywords=full+english"
      content_item_path = "fake/path"

      presenter = SpellingSuggestionPresenter.new(
        suggested_queries,
        url,
        content_item_path,
      )
      expected = [{ data_attributes: {
          ecommerce_path: "fake/path",
          ecommerce_row: 1,
          track_options: {
            dimension81: "full english",
          },
        },
        keywords: "full english",
        highlighted: "<mark>full</mark> english",
        link: "/breakfast-finder?keywords=full+english" }]

      expect(presenter.suggestions).to eq(expected)
    end
  end
end
