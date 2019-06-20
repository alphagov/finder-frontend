# typed: false
require "spec_helper"

RSpec.describe AdvancedSearchResultPresenter do
  let(:finder_content_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
  }
  let(:links) {
    {
      "links" => {
        "taxons" => [{
          "base_path" => "/education",
          "content_id" => taxon_content_id,
          "title" => "Education, training and skills",
        }]
      }
    }
  }
  let(:finder) { AdvancedSearchFinderPresenter.new(finder_content_item.merge(links), {}, {}) }
  let(:document_type) { "guidance" }
  let(:organisations) { [{ title: "Ministry of Defence" }] }
  let(:public_timestamp) { "2018-03-26" }
  let(:content_purpose_supergroup) { "news_and_communications" }
  let(:taxon_content_id) { SecureRandom.uuid }
  let(:search_result) {
    Document.new({
      title: "Result",
      link: "/result",
      content_purpose_supergroup: content_purpose_supergroup,
      content_store_document_type: document_type,
      organisations: organisations,
      public_timestamp: public_timestamp,
    }, finder)
  }
  let(:formatted_metadata) { [{ label: "Public timestamp", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" }] }

  subject(:instance) { described_class.new(search_result, formatted_metadata) }

  describe "#to_hash" do
    it "includes document_type, organisations and publication_date" do
      expect(instance.to_hash[:document_type]).to eq("Guidance")
      expect(instance.to_hash[:organisations]).to eq("Ministry of Defence")
      expect(instance.to_hash[:publication_date][:machine_date]).to eq("2006-07-14")
    end
  end

  context "when metadata is hidden" do
    before { allow(instance).to receive(:show_metadata?).and_return(false) }

    describe "#document_type" do
      it "returns nil" do
        expect(instance.document_type).to be_nil
      end
    end

    describe "#organisations" do
      it "returns nil" do
        expect(instance.organisations).to be_nil
      end
    end

    describe "#publication_date" do
      it "returns nil" do
        expect(instance.publication_date).to be_nil
      end
    end
  end

  describe "#show_metadata?" do
    it "returns true for most document types and supergroups" do
      expect(instance.show_metadata?).to be true
    end

    context "for guide document_type" do
      let(:document_type) { "guide" }

      it "returns false for the 'guide' document_type" do
        expect(instance.show_metadata?).to be false
      end
    end

    context "for services content group" do
      let(:content_purpose_supergroup) { "services" }

      it "returns true for other document_types" do
        expect(instance.show_metadata?).to be false
      end
    end
  end
end
