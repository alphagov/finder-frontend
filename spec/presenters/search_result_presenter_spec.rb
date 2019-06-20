# typed: false
require 'spec_helper'

RSpec.describe SearchResultPresenter do
  subject(:presenter) { SearchResultPresenter.new(document, metadata) }

  let(:document) {
    double(
      Document,
      title: title,
      path: link,
      metadata: metadata,
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
      promoted: false,
      promoted_summary: 'I am a document',
      show_metadata: false,
      format: 'cake',
      es_score: 0.005
    )
  }

  let(:metadata) {
    [
      { id: 'case-state', label: "Case state", value: "Open", is_text: true, labels: nil },
      { label: "Opened date", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" },
      { id: 'case-type', label: "Case type", value: "CA98 and civil cartels", is_text: true, labels: nil },
    ]
  }

  let(:title) { 'Investigation into the distribution of road fuels in parts of Scotland' }
  let(:link) { 'link-1' }

  describe "#to_hash" do
    it "returns a hash" do
      expect(subject.to_hash.is_a?(Hash)).to be_truthy
    end

    it "returns a hash of the data we need to show the document" do
      hash = subject.to_hash
      expect(hash[:title]).to eql(title)
      expect(hash[:link]).to eql(link)
      expect(hash[:metadata]).to eql(metadata)
      expect(hash[:format]).to eql('cake')
      expect(hash[:es_score]).to eql(0.005)
    end
  end
end
