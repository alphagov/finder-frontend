require "spec_helper"

describe Document do
  let(:content_item) {
    FactoryBot.build(:content_item,
                     details: {
                       "show_summaries": show_summaries,
                       "sort": [
                         {
                           "name": "Topic",
                           "key": "topic",
                           "default": true,
                         },
                         {
                           "name": "Most viewed",
                           "key": "-popularity",
                         },
                       ],
                     })
  }

  let(:show_summaries) { true }
  let(:facets) { [] }

  describe "initialization" do
    it "defaults to nil without a public timestamp" do
      document_hash = FactoryBot.build(:document_hash).except("public_timestamp")
      document = Document.new(document_hash, 0)

      expect(document.public_timestamp).to be_nil
    end

    it "returns a link as a path" do
      document_hash = FactoryBot.build(:document_hash, link: "https://link.com/mature-cheeses")
      document = Document.new(document_hash, 0)

      expect(document.path).to eq("https://link.com/mature-cheeses")
    end
  end

  describe "#metadata" do
    context 'There is one facet with type "date"' do
      let(:facets) {
        [FactoryBot.build(:date_facet, key: "a_filter_key")]
      }
      let(:document_hash) {
        FactoryBot.build(:document_hash, a_filter_key: "2019")
      }
      it "gets the metadata" do
        expected_hash =
          {
            name: "A filter key",
            type: "date",
            value: "2019",
          }
        expect(Document.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
      end
    end
    context "There is one facet with type text" do
      let(:facets) {
        [FactoryBot.build(:option_select_facet, key: "a_filter_key")]
      }
      describe "The document is tagged to a single value of the facet filter key" do
        let(:document_hash) {
          FactoryBot.build(:document_hash, a_filter_key: "metadata_label")
        }
        it "gets metadata for a simple text value" do
          expected_hash =
            {
              id: "a_filter_key",
              name: "A filter key",
              value:  "metadata_label",
              labels: %w[metadata_label],
              type: "text",
            }
          expect(Document.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
        end
        describe "There is a short name in the facet" do
          let(:facets) {
            [FactoryBot.build(:option_select_facet, short_name: "short name")]
          }
          it "replaces the name field in the metafata by the short name from the facet" do
            expect(Document.new(document_hash, 1).metadata(facets)).to match([include(name: "short name")])
          end
        end
      end
      describe "The document is tagged to a multiple values of the facet filter key" do
        let(:document_hash) {
          FactoryBot.build(:document_hash,
                           a_filter_key:
                             [
                               { "label" => "metadata_label_1" },
                               { "label" => "metadata_label_2" },
                               { "label" => "metadata_label_3" },
                             ])
        }
        it "gets the metadata" do
          expected_hash =
            {
              id: "a_filter_key",
              name: "A filter key",
              value:  "metadata_label_1 and 2 others",
              labels: %w[metadata_label_1 metadata_label_2 metadata_label_3],
              type: "text",
            }
          expect(Document.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
        end
      end
    end
    describe "The facet key is an organisation or a document collection" do
      let(:facets) {
        [FactoryBot.build(:option_select_facet, key: "organisations"),
         FactoryBot.build(:option_select_facet, key: "document_collections")]
      }
      let(:document_hash) {
        FactoryBot.build(:document_hash,
                         organisations: [{ "title" => "org_title" }],
                         document_collections: [{ "title" => "dc_title" }])
      }
      it "uses title instead of label" do
        expect(Document.new(document_hash, 1).metadata(facets)).
          to match_array([include(value: "org_title"), include(value: "dc_title")])
      end
    end
    describe "the facet key is an organisation and the document is a mainstream document" do
      let(:facets) {
        [FactoryBot.build(:option_select_facet, key: "organisations")]
      }
      let(:document_hash) {
        FactoryBot.build(:document_hash,
                         organisations: [{ "title" => "org_title" }],
                         content_store_document_type: "answer")
      }
      it "does not display metadata because we are not interested in who publishes a mainstream document" do
        expect(Document.new(document_hash, 1).metadata(facets)).to be_empty
      end
    end
  end

  describe "es_score" do
    let(:document_hash) { FactoryBot.build(:document_hash, es_score: 0.005) }

    it "es_score is 0.005" do
      expect(Document.new(document_hash, nil).es_score).to eq 0.005
    end
  end

  describe "#truncated_description" do
    describe "shows the truncated (first sentence) description when a description is present" do
      description = "The government has many departments. These departments are part of the government."
      truncated_description = "The government has many departments."

      let(:with_description_hash) { FactoryBot.build(:document_hash, description_with_highlighting: description) }
      let(:without_description) { FactoryBot.build(:document_hash, description_with_highlighting: nil) }

      it "should have truncated description" do
        expect(Document.new(with_description_hash, 1).truncated_description).to eq(truncated_description)
      end

      it "should not have truncated description" do
        expect(Document.new(without_description, 1).truncated_description).to eq(nil)
      end
    end
  end
end
