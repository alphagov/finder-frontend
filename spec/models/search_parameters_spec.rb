require "spec_helper"

RSpec.describe SearchParameters do
  def search_params(params = {})
    described_class.new(ActionController::Parameters.new(params))
  end

  describe "#search_term" do
    it "truncates a too-long search query" do
      max_length = Search::QueryBuilder::MAX_QUERY_LENGTH
      long_query = "a" * max_length
      params = search_params("q" => "#{long_query}1234567890")
      expect(params.search_term).to eq(long_query)
    end
  end
end
