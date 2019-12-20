require "spec_helper"

describe TopicSearch::QueryBuilder do
  subject(:built_query) { described_class.new.call(search_term) }
  let(:expected_query) do
    { count: 10, q: search_term, fields: %w(taxons title link) }
  end

  context "when a search query is not provided" do
    let(:search_term) { nil }
    it "returns a hash of Search API query params" do
      expect(built_query).to eq(expected_query)
    end
  end

  context "when a search query is provided" do
    let(:search_term) { "Harry Potter" }
    it "returns a hash of Search API query params" do
      expect(built_query).to eq(expected_query)
    end
  end
end
