require "spec_helper"

RSpec.describe SearchResultPresenter do
  let(:content_item) do
    FactoryBot.build(:content_item,
                     content_id: content_id,
                     link: link,
                     details: {
                       'show_summaries': show_summaries,
                     })
  end
  let(:content_id) { "content_id" }
  let(:show_summaries) { true }

  let(:facets) { [] }

  subject(:presenter) {
    SearchResultPresenter.new(document: document,
                              metadata_presenter_class: MetadataPresenter,
                              doc_count: 10,
                              content_item: content_item,
                              facets: facets,
                              debug_score: debug_score,
                              highlight: highlight)
  }
  let(:debug_score) { false }
  let(:highlight) { false }

  let(:document) {
    FactoryBot.build(:document,
                     title: title,
                     link: link,
                     description_with_highlighting: description,
                     is_historic: is_historic,
                     government_name: "Government!",
                     format: "cake",
                     es_score: 0.005,
                     content_id: "content_id",
                     filter_key: "filter_value",
                     index: 1)
  }

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
          data_attributes: {
            ecommerce_path: link,
            ecommerce_row: 1,
            track_category: "navFinderLinkClicked",
            track_action: "finder-title.1",
            track_label: link,
            track_options: {
              dimension28: 10,
              dimension29: title,
            },
          },
        },
        metadata: {},
        metadata_raw: [],
        subtext: nil,
        highlight: false,
        highlight_text: nil,
        parts: [],
      }
      expect(subject.document_list_component_data).to eql(expected_document)
    end
    context "has parts" do
      let(:parts) {
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
      }
      let(:expected_parts) {
        [
          {
            link: {
              text: "I am a part title",
              path: "#{link}/part-path",
              description: "Part description",
              data_attributes: {
                ecommerce_path: "part-path",
                track_category: "resultPart",
                track_action: "Result part",
                track_label: "Part 1",
                track_options: {
                  dimension82: 1,
                },
              },
            },
          },
        ]
      }

      let(:document) {
        FactoryBot.build(:document,
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
                         parts: parts)
      }
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
    let(:facets) { [FactoryBot.build(:option_select_facet, "key" => "filter_key")] }
    context "The content_id is the eu exit finder" do
      let(:content_id) { "42ce66de-04f3-4192-bf31-8394538e0734" }
      it "does not show metadata" do
        expect(subject.document_list_component_data[:metadata]).to be_empty
      end
    end
    context "The content_id is something else than the eu exit finder" do
      let(:content_id) { "not_eu_exit_content_id" }
      it "shows some metadata" do
        expect(subject.document_list_component_data[:metadata]).to_not be_empty
      end
    end


    context "A text based facet and a document tagged to the key of the facet" do
      let(:facets) { [FactoryBot.build(:option_select_facet, key: "a_key_to_filter_on")] }
      let(:document) {
        FactoryBot.build(:document, a_key_to_filter_on: "a_filter_value", index: 1)
      }
      it "displays text based metadata" do
        expect(presenter.document_list_component_data[:metadata]).to eq("A key to filter on" => "A key to filter on: a_filter_value")
      end
    end
    context "A date based facet and a document tagged to the key of the facet" do
      let(:facets) { [FactoryBot.build(:date_facet, "key" => "a_key_to_filter_on")] }
      let(:document) {
        FactoryBot.build(:document, a_key_to_filter_on: "10-10-2009", index: 1)
      }
      it "displays date based metadata" do
        expect(presenter.document_list_component_data[:metadata]).
          to eq("A key to filter on" => 'A key to filter on: <time datetime="2009-10-10">10 October 2009</time>')
      end
    end
  end

  describe "#subtext" do
    let(:historic_subtext) do
      "<span class=\"published-by\">First published during the Government!</span>"
    end
    let(:debug_subtext) do
      "<span class=\"debug-results debug-results--link\">link-1</span><span class=\"debug-results debug-results--meta\">"\
      "Score: 0.005</span><span class=\"debug-results debug-results--meta\">Format: cake</span>"
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
  end

  describe "#summary_text" do
    context "The highlighted parameter is set to true on SearchResultPresenter" do
      let(:highlight) { true }
      context "The finder content item has show_summaries set to true" do
        let(:show_summaries) { true }
        it "returns the truncated description" do
          expect(subject.document_list_component_data[:link][:description]).to eql("I am a document.")
        end
      end
      context "The finder content item has show_summaries set to false" do
        let(:show_summaries) { false }
        it "also returns the truncated description" do
          expect(subject.document_list_component_data[:link][:description]).to eql("I am a document.")
        end
      end
    end
    context "The highlighted parameter is set to false on SearchResultPresenter" do
      let(:highlight) { false }
      context "The finder content item has show_summaries set to true" do
        let(:show_summaries) { true }
        it "returns the truncated description" do
          expect(subject.document_list_component_data[:link][:description]).to eql("I am a document.")
        end
      end
      context "The finder content item has show_summaries set to false" do
        let(:show_summaries) { false }
        it "returns the truncated description" do
          expect(subject.document_list_component_data[:link][:description]).to be_nil
        end
      end
    end
  end

  describe "#highlight_text" do
    context "The highlighted parameter is set to false on SearchResultPresenter" do
      let(:highlight) { false }
      it "returns nothing" do
        expect(subject.document_list_component_data[:highlight_text]).to be nil
      end
    end
    context "The highlighted parameter is set to true on SearchResultPresenter" do
      let(:highlight) { true }
      it "returns 'Most relevant result'" do
        expect(subject.document_list_component_data[:highlight_text]).to eq("Most relevant result")
      end
    end
  end
end
