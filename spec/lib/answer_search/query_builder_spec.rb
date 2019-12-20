require "spec_helper"

describe AnswerSearch::QueryBuilder do
  subject(:built_query) { described_class.new.call(search_term, organisations: organisations) }
  let(:search_term) { nil }
  let(:expected_query) do
    { count: 2, q: search_term, fields: %w(title link) }.merge(additional_filters).compact
  end
  let(:additional_filters) { {} }
  let(:organisations) do
    [
      org("Hogwarts"), org("Ministry of Magic"),
      org("Gringots"), org("Harry Potter World")
    ]
  end

  context "when organisations are not provided" do
    let(:organisations) { [] }

    it "returns the default query" do
      expect(built_query).to eq(expected_query)
    end

    context "with a search term" do
      let(:search_term) { "Harry Potter" }
      it "returns the default query" do
        expect(built_query).to eq(expected_query)
      end
    end
  end

  context "with no search term" do
    it "returns the default query" do
      expect(built_query).to eq(expected_query)
    end
  end

  context "with a typical search term" do
    let(:search_term) { "harry potter world" }
    let(:additional_filters) { { filter_organisations: %w(harry-potter-world) } }
    it "filters by closest organisation" do
      expect(built_query).to eq(expected_query)
    end
  end

  context "with a search term containing a verb" do
    let(:search_term) { "how can I become a Gringots teller?" }
    let(:additional_filters) do
      {
        filter_content_purpose_supergroup: "services",
        filter_organisations: %w(gringots),
      }
    end
    it "filters by service" do
      expect(built_query).to eq(expected_query)
    end
  end

  def org(name)
    {
      "title" => name,
      "slug" => name.downcase.gsub(" ", "-"),
    }
  end
end
