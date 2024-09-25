require "spec_helper"

describe Filters::OfficialDocumentsFilter do
  let(:filter) do
    described_class.new(facet, "params_value")
  end
  let(:hashes) do
    Filters::OfficialDocumentsHashes.new.call
  end

  let(:facet) { { "key" => "content_store_document_type" } }

  describe "#filter_hashes" do
    it "returns valid official_documents filter hashes" do
      expect(filter.filter_hashes).to eq(hashes)
    end
  end
end
