require "spec_helper"

describe AnswerSearch::Answer do
  subject(:answer) { described_class.new(search_query, search_results).find }
  let(:search_query) { "Harry potter" }
  let(:search_results) { [] }

  context "when no search query is provided" do
    let(:search_query) { nil }
    it "returns no answer" do
      expect(answer).to be_nil
    end
  end

  context "when search results are not provided" do
    let(:search_results) { [] }
    it "returns no answer" do
      expect(answer).to be_nil
    end
  end

  context "when the results don't match the query" do
    # - Levenshtein distance between query and top link is high
    # - es_scores are close together
    let(:search_results) do
      [
        { "link" => "/hagrid",       "es_score" => 0.008 },
        { "link" => "/ron-weasley",  "es_score" => 0.008 },
      ]
    end

    it "returns no answer" do
      expect(answer).to be_nil
    end
  end

  context "when the top result is significantly better" do
    let(:search_results) do
      [
        { "link" => "/hagrid",       "es_score" => 0.02 },
        { "link" => "/ron-weasley",  "es_score" => 0.008 },
      ]
    end

    it "returns the top result" do
      expect(answer).to eq search_results.first
    end
  end

  context "when the Levenshtein distance between the query and result link is LOW" do
    let(:search_results) do
      [
        { "link" => "/harry-potter", "es_score" => 0.008 },
        { "link" => "/ron-weasley",  "es_score" => 0.008 },
      ]
    end

    it "returns the top result" do
      expect(answer).to eq search_results.first
    end
  end
end
