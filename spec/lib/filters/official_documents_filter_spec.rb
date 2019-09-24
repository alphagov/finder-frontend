require "spec_helper"

describe Filters::OfficialDocumentsFilter do
  let(:filter) {
    Filters::OfficialDocumentsFilter.new(facet, "params_value")
  }
  let(:hashes) {
    Filters::OfficialDocumentsHashes.new.call
  }

  let(:facet) { { "key" => "content_store_document_type" } }

  describe "#filter_hashes" do
    it "returns valid official_documents filter hashes" do
      expect(filter.filter_hashes).to eq(hashes)
    end
  end
end
