require "spec_helper"

RSpec.describe EntryPresenter do
  describe "#summary" do
    let(:document) do
      FactoryBot.build(:document, description_with_highlighting: "This is the summary. And this is extra.")
    end
    it "displays the truncated description" do
      expect(EntryPresenter.new(document, true).summary).to eq("This is the summary. And this is extra.")
    end
    it "returns nil" do
      expect(EntryPresenter.new(document, false).summary).to be nil
    end
  end
  describe "#tag" do
    it "returns a tag" do
      document = FactoryBot.build(:document, link: "/path/to/content")
      atom_feed_builder = ActionView::Helpers::AtomFeedHelper::AtomFeedBuilder.new(nil, nil, schema_date: 2019)
      expect(EntryPresenter.new(document, true).tag(atom_feed_builder)).to eq("tag:www.test.gov.uk,2019:/path/to/content")
    end
  end
  describe "#updated_at" do
    it "returns the public timestamp" do
      document = FactoryBot.build(:document, public_timestamp: "Thu Nov 29 14:33:20 2001", release_timestamp: "Thu Nov 29 14:33:20 2010")
      expect(EntryPresenter.new(document, true).updated_at).to eq("Thu Nov 29 14:33:20 2001")
    end
    it "returns the release timestamp" do
      document = FactoryBot.build(:document, public_timestamp: nil, release_timestamp: "Thu Nov 29 14:33:20 2010")
      expect(EntryPresenter.new(document, true).updated_at).to eq("Thu Nov 29 14:33:20 2010")
    end
  end
  describe "#feed_ended_id" do
    it "returns a feed_ended_id" do
      atom_feed_builder = ActionView::Helpers::AtomFeedHelper::AtomFeedBuilder.new(nil, nil, schema_date: 2019)
      expect(EntryPresenter.feed_ended_id(atom_feed_builder, "/path/to/content")).to eq("tag:www.test.gov.uk,2019:/path/to/content/feed-ended")
    end
  end

  # Note - this is a simple delegation and we wouldn't normally test, but
  # it's important for email-alert-api's monitoring of medical alerts, so
  # worth checking that it hasn't been accidentally removed.
  describe "#content_id" do
    let(:document) do
      FactoryBot.build(:document, content_id: "AAAA-BBBB")
    end
    it "displays the content_id" do
      expect(EntryPresenter.new(document, true).content_id).to eq("AAAA-BBBB")
    end
  end
end
