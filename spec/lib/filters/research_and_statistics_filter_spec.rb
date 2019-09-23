require "spec_helper"

describe Filters::ResearchAndStatisticsFilter do
  let(:filter) {
    Filters::ResearchAndStatisticsFilter.new(facet, "params_value")
  }
  let(:hashes) {
    Filters::ResearchAndStatsHashes.new.call
  }

  let(:facet) { { "key" => "content_store_document_type" } }

  describe "#filter_hashes" do
    it "returns valid reearch and stats filter hashes" do
      expect(filter.filter_hashes).to eq(hashes)
    end
  end
end
