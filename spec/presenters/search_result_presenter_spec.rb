require "spec_helper"

RSpec.describe SearchResultPresenter do
  let(:content_item) do
    FactoryBot.build(
      :content_item,
      content_id: content_id,
      link: link,
      details: {
        'show_summaries': show_summaries,
      },
    )
  end
  let(:content_id) { "content_id" }
  let(:show_summaries) { true }

  let(:facets) { [] }

  let(:rank) { 1 }

  subject(:presenter) do
    SearchResultPresenter.new(
      document: document,
      rank: rank,
      metadata_presenter_class: MetadataPresenter,
      doc_count: 10,
      content_item: content_item,
      facets: facets,
      debug_score: debug_score,
    )
  end
  let(:debug_score) { false }

  let(:document) do
    FactoryBot.build(
      :document,
      title: title,
      link: link,
      description_with_highlighting: description,
      is_historic: is_historic,
      government_name: "Government!",
      format: "cake",
      es_score: 0.005,
      combined_score: combined_score,
      original_rank: original_rank,
      content_id: "content_id",
      filter_key: "filter_value",
      index: 1,
    )
  end

  let(:combined_score) { nil }
  let(:original_rank) { nil }

  let(:is_historic) { false }
  let(:title) { "Investigation into the distribution of road fuels in parts of Scotland" }
  let(:link) { "link-1" }
  let(:description) { "I am a document. I am full of words and that." }

  describe "#document_list_component_data" do
    it "returns a hash of the data we need to show the document" do
      expected_document = {
        link: {
          text: title,
          path: link,
          description: "I am a document.",
        },
        metadata: {},
        metadata_raw: [],
        subtext: nil,
        parts: [],
      }
      expect(subject.document_list_component_data).to eql(expected_document)
    end
    context "has parts" do
      let(:parts) do
        [
          {
            title: "I am a part title",
            slug: "part-path",
            body: "Part description",
          },
          {
            title: "I am a part title 2",
            slug: "part-path2",
          },
        ]
      end
      let(:expected_parts) do
        [
          {
            link: {
              text: "I am a part title",
              path: "#{link}/part-path",
              description: "Part description",
            },
          },
        ]
      end

      let(:document) do
        FactoryBot.build(
          :document,
          title: title,
          link: link,
          description_with_highlighting: description,
          is_historic: is_historic,
          government_name: "Government!",
          format: "cake",
          es_score: 0.005,
          content_id: "content_id",
          filter_key: "filter_value",
          index: 1,
          parts: parts,
        )
      end
      it "shows only parts with required data" do
        expect(subject.document_list_component_data[:parts]).to eq(expected_parts)
      end

      it "notifies of a validation error for missing part data" do
        expect(GovukError).to receive(:notify).with(
          instance_of(described_class::MalformedPartError),
          extra: {
            part: { title: "I am a part title 2", slug: "part-path2" },
            link: "link-1",
          },
        )
        subject.document_list_component_data
      end
    end
  end

  describe "structure_metadata" do
    context "A text based facet and a document tagged to the key of the facet" do
      let(:facets) { [FactoryBot.build(:option_select_facet, key: "a_key_to_filter_on")] }
      let(:document) do
        FactoryBot.build(:document, a_key_to_filter_on: "a_filter_value", index: 1)
      end
      it "displays text based metadata" do
        expect(presenter.document_list_component_data[:metadata]).to eq("A key to filter on" => "A key to filter on: a_filter_value")
      end
    end
    context "A date based facet and a document tagged to the key of the facet" do
      let(:facets) { [FactoryBot.build(:date_facet, "key" => "a_key_to_filter_on")] }
      let(:document) do
        FactoryBot.build(:document, a_key_to_filter_on: "10-10-2009", index: 1)
      end
      it "displays date based metadata" do
        expect(presenter.document_list_component_data[:metadata])
          .to eq("A key to filter on" => 'A key to filter on: <time datetime="2009-10-10">10 October 2009</time>')
      end
    end
  end

  describe "#subtext" do
    let(:historic_subtext) do
      "<span class=\"published-by\">First published during the Government!</span>"
    end
    let(:debug_subtext) do
      "<span class=\"debug-results debug-results--link\">link-1</span><span class=\"debug-results debug-results--meta\">"\
      "Score: 0.005 (ranked #1)</span><span class=\"debug-results debug-results--meta\">Format: cake</span>"
    end
    it "returns nothing unless the document is historic or debug_score is set to true" do
      expect(subject.document_list_component_data[:subtext]).to eql(nil)
    end

    context "The document is historic" do
      let(:is_historic) { true }
      it "returns 'Published by' text" do
        expect(subject.document_list_component_data[:subtext]).to eql(historic_subtext)
      end
    end

    context "debug_score is true" do
      let(:debug_score) { true }
      it "returns debug metadata" do
        expect(subject.document_list_component_data[:subtext]).to eql(debug_subtext)
      end
    end

    context "The document is historic and the debug_score is true" do
      let(:is_historic) { true }
      let(:debug_score) { true }
      it "returns 'Published by' and debug metadata together" do
        expect(subject.document_list_component_data[:subtext]).to eql("#{historic_subtext}#{debug_subtext}")
      end
    end

    context "The document has been reranked" do
      let(:combined_score) { 8 }
      let(:original_rank) { 3 }
      let(:debug_score) { true }

      let(:debug_subtext) do
        "<span class=\"debug-results debug-results--link\">link-1</span>"\
        "<span class=\"debug-results debug-results--meta\">Score: #{combined_score} (ranked #1)</span>"\
        "<span class=\"debug-results debug-results--meta\">Original score: 0.005 (ranked ##{original_rank})</span>"\
        "<span class=\"debug-results debug-results--meta\">Format: cake</span>"
      end

      it "gives the original score and rank in the debug text" do
        expect(subject.document_list_component_data[:subtext]).to eql(debug_subtext)
      end
    end
  end
end
