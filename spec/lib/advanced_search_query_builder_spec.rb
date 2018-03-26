require "spec_helper"

RSpec.describe AdvancedSearchQueryBuilder do
  subject(:instance) { described_class.new(finder_content_item: {}) }
  describe "#base_return_fields" do
    it "includes document_type and organisations" do
      expect(instance.base_return_fields).to include("content_store_document_type")
      expect(instance.base_return_fields).to include("organisations")
    end
  end
end
