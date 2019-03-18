require 'spec_helper'

RSpec.describe SearchResultPresenter do
  subject(:presenter) { SearchResultPresenter.new(document) }

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
      es_score: 0.005,
      top_result: false
    )
  }

  let(:title) { 'Investigation into the distribution of road fuels in parts of Scotland' }
  let(:link) { 'link-1' }

  let(:metadata) {
    [
      { id: 'case-state', name: 'Case state', value: 'Open', type: 'text' },
      { id: 'opened-date', name: 'Opened date', value: '2006-7-14', type: 'date' },
      { id: 'case-type', name: 'Case type', value: 'CA98 and civil cartels', type: 'text' },
    ]
  }

  describe "#to_hash" do
    it "returns a hash" do
      expect(subject.to_hash.is_a?(Hash)).to be_truthy
    end

    let(:formatted_metadata) {
      [
        { id: 'case-state', label: "Case state", value: "Open", is_text: true, labels: nil },
        { label: "Opened date", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" },
        { id: 'case-type', label: "Case type", value: "CA98 and civil cartels", is_text: true, labels: nil },
      ]
    }

    it "returns a hash of the data we need to show the document" do
      hash = subject.to_hash
      expect(hash[:title]).to eql(title)
      expect(hash[:link]).to eql(link)
      expect(hash[:metadata]).to eql(formatted_metadata)
      expect(hash[:es_score]).to eql(0.005)
      expect(hash[:top_result]).to eql(false)
    end
  end

  describe '#metadata' do
    it 'returns an array' do
      expect(subject.metadata.is_a?(Array)).to be_truthy
    end

    it 'formats metadata' do
      allow(presenter).to receive(:build_text_metadata).and_call_original
      allow(presenter).to receive(:build_date_metadata).and_call_original

      subject.metadata
      expect(subject).to have_received(:build_date_metadata).with(
        id: "opened-date",
        name: "Opened date",
        value: "2006-7-14",
        type: "date"
      )
      expect(subject).to have_received(:build_text_metadata).with(
        id: "case-state",
        name: "Case state",
        value: "Open",
        type: "text"
      )
      expect(subject).to have_received(:build_text_metadata).with(
        id: "case-state",
        name: "Case state",
        value: "Open",
        type: "text"
      )
    end
  end

  describe '#build_text_metadata' do
    let(:data) {
      { name: 'some name', value: 'some value' }
    }
    it 'returns a hash' do
      expect(subject.build_text_metadata(data).is_a?(Hash)).to be_truthy
    end
    it 'sets the type to text' do
      expect(subject.build_text_metadata(data).fetch(:is_text)).to be_truthy
    end
  end

  describe '#build_date_metadata' do
    let(:data) {
      { name: 'some name', value: raw_date }
    }
    let(:raw_date) { '2003-12-01' }
    let(:formatted_date) { '1 December 2003' }
    let(:iso_date) { '2003-12-01' }

    it 'returns a hash' do
      expect(subject.build_date_metadata(data).is_a?(Hash)).to be_truthy
    end

    it 'sets the type to date' do
      expect(subject.build_date_metadata(data).fetch(:is_date)).to be_truthy
    end

    it 'formats the date' do
      date_metadata = subject.build_date_metadata(data)
      expect(date_metadata.fetch(:human_date)).to eql(formatted_date)
      expect(date_metadata.fetch(:machine_date)).to eql(iso_date)
    end
  end
end
