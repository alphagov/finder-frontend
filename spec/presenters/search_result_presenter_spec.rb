require "spec_helper"

RSpec.describe SearchResultPresenter do
  subject(:presenter) do
    described_class.new(
      document:,
      rank:,
      result_number:,
      metadata_presenter_class: MetadataPresenter,
      doc_count: 10,
      content_item:,
      facets:,
      debug_score:,
      full_size_description:,
    )
  end

  let(:content_item) do
    FactoryBot.build(
      :content_item,
      content_id:,
      link:,
      details: {
        'show_summaries': show_summaries,
      },
    )
  end
  let(:debug_score) { false }
  let(:document) do
    FactoryBot.build(
      :document,
      title:,
      link:,
      description_with_highlighting: description,
      is_historic:,
      government_name: "Government!",
      format: "cake",
      es_score: 0.005,
      combined_score:,
      original_rank:,
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
  let(:content_id) { "content_id" }
  let(:show_summaries) { true }
  let(:full_size_description) { false }

  let(:facets) { [] }

  let(:rank) { 1 }
  let(:result_number) { 1 }

  describe "#document_list_component_data" do
    it "returns a hash of the data we need to show the document" do
      expected_document = {
        link: {
          text: title,
          path: link,
          description: "I am a document. I am full of words and that.",
          full_size_description: false,
          data_attributes: {
            ga4_ecommerce_path: link,
            ga4_ecommerce_content_id: "content_id",
            ga4_ecommerce_row: 1,
            ga4_ecommerce_index: 1,
          },
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

      let(:document) do
        FactoryBot.build(
          :document,
          title:,
          link:,
          description_with_highlighting: description,
          is_historic:,
          government_name: "Government!",
          format: "cake",
          es_score: 0.005,
          content_id: "content_id",
          filter_key: "filter_value",
          index: 1,
          parts:,
        )
      end

      context "when the result is number 3 or lower" do
        let(:result_number) { 3 }

        let(:expected_parts) do
          [
            {
              link: {
                text: "I am a part title",
                path: "#{link}/part-path",
                description: "Part description",
                data_attributes: {
                  ga4_ecommerce_path: "#{link}/part-path",
                  ga4_ecommerce_content_id: "content_id",
                  ga4_ecommerce_row: 1,
                  ga4_ecommerce_index: 1,
                },
              },
            },
          ]
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

      context "when the result is number 4 or higher" do
        let(:result_number) { 4 }

        it "does not show any parts" do
          expect(subject.document_list_component_data[:parts]).to be_nil
        end
      end

      context "when a part has a blank slug" do
        let(:parts) do
          [
            {
              title: "I am a part title",
              slug: "part-path",
              body: "Part description",
            },
            {
              title: "I am missing slug",
              slug: "",
              body: "Body text",
            },
          ]
        end

        let(:result_number) { 3 }

        let(:expected_parts) do
          [
            {
              link: {
                text: "I am a part title",
                path: "#{link}/part-path",
                description: "Part description",
                data_attributes: {
                  ga4_ecommerce_path: "#{link}/part-path",
                  ga4_ecommerce_content_id: "content_id",
                  ga4_ecommerce_row: 1,
                  ga4_ecommerce_index: 1,
                },
              },
            },
          ]
        end

        it "skips the part with a blank slug without notifying" do
          expect(subject.document_list_component_data[:parts]).to eq(expected_parts)
        end
      end
    end

    context "with full size description" do
      let(:full_size_description) { true }

      it "returns link items with the full_size_description attribute set to true" do
        expect(subject.document_list_component_data[:link][:full_size_description]).to be(true)
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
      expect(subject.document_list_component_data[:subtext]).to be_nil
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
