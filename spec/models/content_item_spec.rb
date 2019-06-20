# typed: false
require "spec_helper"

describe ContentItem do
  subject { described_class.new(base_path) }
  let(:base_path) { "/search/news-and-communications" }
  let(:finder_content_item) { news_and_communications }
  let(:news_and_communications) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "news_and_communications.json")))
  }

  before do
    allow(Services.content_store).to receive(:content_item)
      .with(base_path)
      .and_return(finder_content_item)
  end

  before :each do
    Rails.cache.clear
  end

  after :each do
    Rails.cache.clear
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
      let(:finder_content_item) { news_and_communications.merge("document_type" => 'search') }
      it "returns true when document_type is search" do
        expect(subject.is_search?).to be true
      end
    end
  end

  describe "is_finder?" do
    it "returns true when document_type is not finder" do
      expect(subject.is_finder?).to be true
    end

    context "when document_type is not a finder" do
      let(:finder_content_item) { news_and_communications.merge("document_type" => 'search') }
      it "returns false when document_type is finder" do
        expect(subject.is_finder?).to be false
      end
    end
  end

  describe "is_redirect?" do
    it "returns false when document_type is not redirect" do
      expect(subject.is_redirect?).to be false
    end

    context "when document_type is redirect" do
      let(:finder_content_item) { news_and_communications.merge("document_type" => 'redirect') }
      it "returns true when document_type is redirect" do
        expect(subject.is_redirect?).to be true
      end
    end
  end
end
