require "spec_helper"
require "gds_api/test_helpers/content_store"

describe ContentItem do
  include ::GdsApi::TestHelpers::ContentStore

  subject { described_class.new(finder_content_item) }
  let(:finder_content_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "news_and_communications.json")))
  }

  describe "load a content item from the content store" do
    let(:base_path) { "/search/news-and-communications" }

    it "returns a content item as a hash" do
      content_store_has_item(base_path, finder_content_item)
      expect(ContentItem.from_content_store(base_path).as_hash).to eql(finder_content_item)
    end
  end

  describe "as_hash" do
    it "returns a content item as a hash" do
      expect(subject.as_hash).to eql(finder_content_item)
    end
  end

  describe "is_search?" do
    it "returns false when document_type is not search" do
      expect(subject.is_search?).to be false
    end

    context "when document_type is search" do
      it "returns true when document_type is search" do
        finder_content_item.merge!("document_type" => "search")
        expect(subject.is_search?).to be true
      end
    end
  end

  describe "is_finder?" do
    it "returns true when document_type is not finder" do
      expect(subject.is_finder?).to be true
    end

    context "when document_type is not a finder" do
      it "returns false when document_type is finder" do
        finder_content_item.merge!("document_type" => "search")
        expect(subject.is_finder?).to be false
      end
    end
  end

  describe "is_redirect?" do
    it "returns false when document_type is not redirect" do
      expect(subject.is_redirect?).to be false
    end

    context "when document_type is redirect" do
      it "returns true when document_type is redirect" do
        finder_content_item.merge!("document_type" => "redirect")
        expect(subject.is_redirect?).to be true
      end
    end
  end
end
