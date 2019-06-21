require 'spec_helper'

RSpec.describe SearchResultPresenter do
  let(:finder_name) { 'Finder name' }
  let(:doc_index) { 0 }
  let(:doc_count) { 1 }
  let(:debug_score) { false }
  let(:highlight) { false }

  subject(:presenter) {
    SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: highlight)
  }

  let(:title) { 'Investigation into the distribution of road fuels in parts of Scotland' }
  let(:link) { 'link-1' }
  let(:summary) { 'I am a document. I am full of words and that.' }

  let(:document) {
    double(
      Document,
      title: title,
      path: link,
      metadata: metadata,
      summary: summary,
      truncated_description: "I am a document.",
      is_historic: false,
      government_name: 'Government!',
      show_metadata: false,
      format: 'cake',
      es_score: 0.005
    )
  }

  let(:document_with_metadata) {
    double(
      Document,
      title: title,
      path: link,
      metadata: metadata,
      summary: summary,
      is_historic: true,
      government_name: 'Government!',
      show_metadata: true,
      format: 'cake',
      es_score: 0.005
    )
  }

  let(:metadata) {
    [
      { id: 'case-state', label: "Case state", value: "Open", is_text: true, labels: nil },
      { label: "Opened date", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" },
      { id: 'case-type', label: "Case type", value: "CA98 and civil cartels", is_text: true, labels: nil, hide_label: true },
    ]
  }

  let(:expected_document) {
    {
      link: {
        text: title,
        path: link,
        description: summary,
        data_attributes: {
          track_category: "navFinderLinkClicked",
          track_action: "#{finder_name}.1",
          track_label: link,
          track_options: {
            dimension28: doc_count,
            dimension29: title
          }
        }
      },
      metadata: {},
      metadata_raw: metadata,
      subtext: nil,
      highlight: false,
      highlight_text: nil
    }
  }

  describe "#to_hash" do
    it "returns a hash" do
      expect(subject.to_hash.is_a?(Hash)).to be_truthy
    end

    it "returns a hash of the data we need to show the document" do
      hash = subject.to_hash

      expect(hash).to eql(expected_document)
    end
  end

  describe "structure_metadata" do
    it "returns nothing unless show_metadata" do
      expect(subject.structure_metadata).to eql({})
    end

    it "returns structured data if show_metadata is true" do
      with_metadata = SearchResultPresenter.new(search_result: document_with_metadata, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: highlight)

      expect(with_metadata.structure_metadata).to eql(
        "Case state" => "Case state: Open",
        "Case type" => "<span class=\"govuk-visually-hidden\">Case type:</span> CA98 and civil cartels",
        "Opened date" => "Opened date: <time datetime=\"2006-07-14\">14 July 2006</time>"
      )
    end
  end

  describe "subtext" do
    let(:historic_subtext) { "<span class=\"published-by\">First published during the Government!</span>" }
    let(:debug_subtext) { "<span class=\"debug-results debug-results--link\">link-1</span><span class=\"debug-results debug-results--meta\">Score: 0.005</span><span class=\"debug-results debug-results--meta\">Format: cake</span>" }

    it "returns nothing unless is_historic or debug_score" do
      expect(subject.subtext).to eql(nil)
    end

    it "returns 'Published by' text if is_historic is true" do
      with_historic = SearchResultPresenter.new(search_result: document_with_metadata, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: highlight)

      expect(with_historic.subtext).to eql(historic_subtext)
    end

    it "returns debug metadata if debug_score" do
      with_debug = SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: 1, highlight: highlight)

      expect(with_debug.subtext).to eql(debug_subtext)
    end

    it "returns 'Published by' and debug metadata together" do
      with_all = SearchResultPresenter.new(search_result: document_with_metadata, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: 1, highlight: highlight)

      expect(with_all.subtext).to eql("#{historic_subtext}#{debug_subtext}")
    end
  end

  describe "summary_text" do
    it "returns summary if not highlighted" do
      no_highlight = SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: false)

      expect(no_highlight.summary_text).to eql(summary)
    end

    it "returns truncated summary if highlighted" do
      with_highlight = SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: true)

      expect(with_highlight.summary_text).to eql("I am a document.")
    end
  end

  describe "highlight_text" do
    it "returns nothing if not highlight" do
      no_highlight = SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: false)

      expect(no_highlight.highlight_text).to eql(nil)
    end

    it "returns 'Most relevant result' if highlight" do
      no_highlight = SearchResultPresenter.new(search_result: document, metadata: metadata, doc_index: doc_index, doc_count: doc_count, finder_name: finder_name, debug_score: debug_score, highlight: true)

      expect(no_highlight.highlight_text).to eql("Most relevant result")
    end
  end
end
