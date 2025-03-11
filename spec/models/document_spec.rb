require "spec_helper"

describe Document do
  let(:content_item) do
    FactoryBot.build(
      :content_item,
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
      },
    )
  end

  let(:show_summaries) { true }
  let(:facets) { [] }

  describe "initialization" do
    it "defaults to nil without a public timestamp" do
      document_hash = FactoryBot.build(:document_hash).except("public_timestamp")
      document = described_class.new(document_hash, 0)

      expect(document.public_timestamp).to be_nil
    end

    it "returns a link as a path" do
      document_hash = FactoryBot.build(:document_hash, link: "https://link.com/mature-cheeses")
      document = described_class.new(document_hash, 0)

      expect(document.path).to eq("https://link.com/mature-cheeses")
    end
  end

  describe "#metadata" do
    context 'There is one facet with type "date"' do
      let(:facets) do
        [FactoryBot.build(:date_facet, key: "a_filter_key")]
      end
      let(:document_hash) do
        FactoryBot.build(:document_hash, a_filter_key: "2019")
      end

      it "gets the metadata" do
        expected_hash =
          {
            name: "A filter key",
            type: "date",
            value: "2019",
          }
        expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
      end
    end

    context "There is one facet with type text" do
      let(:facets) do
        [FactoryBot.build(:option_select_facet, key: "a_filter_key")]
      end

      describe "and the document is not tagged to any values of the facet filter key" do
        let(:document_hash) do
          FactoryBot.build(:document_hash, a_filter_key: nil)
        end

        it "does not return any metadata" do
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq([])
        end
      end

      describe "and the document values do not match the expected format" do
        let(:document_hash) do
          FactoryBot.build(:document_hash, a_filter_key: [{ slug: "some-url" }])
        end

        it "does not return any metadata" do
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq([])
        end
      end

      describe "and the document is tagged to a single value of the facet filter key" do
        let(:document_hash) do
          FactoryBot.build(:document_hash, a_filter_key: "metadata_label_1")
        end

        it "gets metadata for a simple text value" do
          expected_hash =
            {
              id: "a_filter_key",
              name: "A filter key",
              value: "metadata_label_1",
              labels: %w[metadata_label_1],
              type: "text",
            }
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
        end

        describe "and there is a short name in the facet" do
          let(:facets) do
            [FactoryBot.build(:option_select_facet, short_name: "short name")]
          end

          it "replaces the name field in the metadata by the short name from the facet" do
            expect(described_class.new(document_hash, 1).metadata(facets)).to match([include(name: "short name")])
          end
        end

        context "and the facet has a set of allowed values" do
          let(:allowed_values) do
            [
              { "label" => "metadata label 1", value: "metadata_label_1" },
              { "label" => "metadata label 2", value: "metadata_label_2" },
              { "label" => "metadata label 3", value: "metadata_label_3" },
            ]
          end
          let(:facets) do
            [FactoryBot.build(:option_select_facet, key: "a_filter_key", allowed_values:)]
          end

          it "gets the metadata" do
            expected_hash =
              {
                id: "a_filter_key",
                name: "A filter key",
                value: "metadata label 1",
                labels: ["metadata label 1"],
                type: "text",
              }
            expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
          end
        end
      end

      describe "and the document is tagged to multiple values of the facet filter key" do
        let(:document_hash) do
          FactoryBot.build(
            :document_hash,
            a_filter_key:
              [
                { "label" => "metadata_label_1" },
                { "label" => "metadata_label_2" },
                { "label" => "metadata_label_3" },
              ],
          )
        end

        it "gets the metadata" do
          expected_hash =
            {
              id: "a_filter_key",
              name: "A filter key",
              value: "metadata_label_1 and 2 others",
              labels: %w[metadata_label_1 metadata_label_2 metadata_label_3],
              type: "text",
            }
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
        end
      end

      context "and the facet has a set of allowed values" do
        let(:allowed_values) do
          [
            { "label" => "metadata label 1", value: "metadata_label_1" },
            { "label" => "metadata label 2", value: "metadata_label_2" },
            { "label" => "metadata label 3", value: "metadata_label_3" },
          ]
        end
        let(:facets) do
          [FactoryBot.build(:option_select_facet, key: "a_filter_key", allowed_values:)]
        end

        describe "and the document is tagged to multiple values of the facet filter key" do
          let(:document_hash) do
            FactoryBot.build(
              :document_hash,
              a_filter_key:
                [
                  { "label" => "metadata label 1", value: "metadata_label_1" },
                  { "label" => "metadata label 3", value: "metadata_label_3" },
                ],
            )
          end

          it "gets the metadata" do
            expected_hash =
              {
                id: "a_filter_key",
                name: "A filter key",
                value: "metadata label 1 and 1 others",
                labels: ["metadata label 1", "metadata label 3"],
                type: "text",
              }
            expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
          end
        end

        describe "and the document is tagged to a multiple values of the facet filter key that do not match any allowed values" do
          let(:document_hash) do
            FactoryBot.build(
              :document_hash,
              a_filter_key:
                [
                  { "label" => "mismatched label 1", value: "mismatched_label_1" },
                  { "label" => "mismatched label 3", value: "mismatched_label_3" },
                ],
            )
          end

          it "gets the metadata" do
            expected_hash =
              {
                id: "a_filter_key",
                name: "A filter key",
                value: "mismatched label 1 and 1 others",
                labels: ["mismatched label 1", "mismatched label 3"],
                type: "text",
              }
            expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
          end
        end

        describe "and the document is tagged to a multiple values of the facet filter key without search result expansion" do
          let(:document_hash) do
            FactoryBot.build(
              :document_hash,
              a_filter_key:
                %w[metadata_label_1 metadata_label_3],
            )
          end

          it "gets the metadata" do
            expected_hash =
              {
                id: "a_filter_key",
                name: "A filter key",
                value: "metadata label 1 and 1 others",
                labels: ["metadata label 1", "metadata label 3"],
                type: "text",
              }
            expect(described_class.new(document_hash, 1).metadata(facets)).to eq([expected_hash])
          end
        end
      end
    end

    context "There is one facet of type nested" do
      let(:allowed_values) do
        [
          {
            "label": "Allowed value 1 label",
            "value": "allowed-value-1",
            "sub_facets": [
              {
                "label": "Sub facet Value 1 label",
                "value": "allowed-value-1-sub-facet-value-1",
                "main_facet_label": "Allowed value 1 label",
                "main_facet_value": "allowed-value-1",
              },
              {
                "label": "Sub facet Value 2 label",
                "value": "allowed-value-1-sub-facet-value-2",
                "main_facet_label": "Allowed value 1 label",
                "main_facet_value": "allowed-value-1",
              },
            ],
          },
          {
            "label": "Allowed value 2 label",
            "value": "allowed-value-2",
          },
        ]
      end
      let(:facets) do
        [FactoryBot.build(:nested_facet,
                          type: "nested",
                          name: "Facet Name",
                          short_name: "Main Facet Short Name",
                          key: "main_facet_key_value",
                          sub_facet_key: "sub_facet_key_value",
                          sub_facet_name: "Sub Facet Name",
                          nested_facet: true,
                          allowed_values:)]
      end

      describe "and the document is tagged to multiple values of both main and sub facet filter keys" do
        let(:document_hash) do
          FactoryBot.build(
            :document_hash,
            main_facet_key_value:
              [
                { "label" => "Allowed value 1 label", value: "allowed-value-1" },
                { "label" => "Allowed value 2 label", value: "allowed-value-2" },
              ],
            sub_facet_key_value: [
              { "label" => "Sub facet Value 1 label", value: "allowed-value-1-sub-facet-value-1" },
              { "label" => "Sub facet Value 2 label", value: "allowed-value-1-sub-facet-value-2" },
            ],
          )
        end

        it "gets the metadata" do
          expected_hash =
            [
              {
                id: "main_facet_key_value",
                name: "Main Facet Short Name",
                value: "Allowed value 1 label and 1 others",
                labels: ["Allowed value 1 label", "Allowed value 2 label"],
                type: "nested",
              },
              {
                id: "sub_facet_key_value",
                name: "Sub Facet Name",
                value: "Sub facet Value 1 label and 1 others",
                labels: ["Sub facet Value 1 label", "Sub facet Value 2 label"],
                type: "nested",
              },
            ]
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq(expected_hash)
        end
      end

      describe "and the document is tagged to a multiple values of the main and sub-facet facet filter keys that do not match any allowed values" do
        let(:document_hash) do
          FactoryBot.build(
            :document_hash,
            main_facet_key_value:
              [
                { "label" => "mismatched label 1", value: "mismatched_label_1" },
                { "label" => "mismatched label 3", value: "mismatched_label_3" },
              ],
            sub_facet_key_value:
            [
              { "label" => "mismatched label 1", value: "mismatched_label_1" },
              { "label" => "mismatched label 3", value: "mismatched_label_3" },
            ],
          )
        end

        it "gets the metadata" do
          expected_hash =
            [
              {
                id: "main_facet_key_value",
                name: "Main Facet Short Name",
                value: "mismatched label 1 and 1 others",
                labels: ["mismatched label 1", "mismatched label 3"],
                type: "nested",
              },
              {
                id: "sub_facet_key_value",
                name: "Sub Facet Name",
                value: "mismatched label 1 and 1 others",
                labels: ["mismatched label 1", "mismatched label 3"],
                type: "nested",
              },
            ]
          expect(described_class.new(document_hash, 1).metadata(facets)).to eq(expected_hash)
        end
      end
    end

    describe "The facet key is an organisation or a document collection" do
      let(:facets) do
        [FactoryBot.build(:option_select_facet, key: "organisations"),
         FactoryBot.build(:option_select_facet, key: "document_collections")]
      end
      let(:document_hash) do
        FactoryBot.build(
          :document_hash,
          organisations: [{ "title" => "org_title" }],
          document_collections: [{ "title" => "dc_title" }],
        )
      end

      it "uses title instead of label" do
        expect(described_class.new(document_hash, 1).metadata(facets))
          .to contain_exactly(include(value: "org_title"), include(value: "dc_title"))
      end
    end

    describe "the facet key is an organisation and the document is a mainstream document" do
      let(:facets) do
        [FactoryBot.build(:option_select_facet, key: "organisations")]
      end
      let(:document_hash) do
        FactoryBot.build(
          :document_hash,
          organisations: [{ "title" => "org_title" }],
          content_store_document_type: "answer",
        )
      end

      it "does not display metadata because we are not interested in who publishes a mainstream document" do
        expect(described_class.new(document_hash, 1).metadata(facets)).to be_empty
      end
    end
  end

  describe "es_score" do
    let(:document_hash) { FactoryBot.build(:document_hash, es_score: 0.005) }

    it "es_score is 0.005" do
      expect(described_class.new(document_hash, nil).es_score).to eq 0.005
    end
  end
end
