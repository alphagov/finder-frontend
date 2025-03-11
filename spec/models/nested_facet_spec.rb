require "spec_helper"

describe NestedFacet do
  subject { described_class.new(facet_hash, value_hash) }

  let(:facet_hash) do
    {
      "allowed_values" => allowed_values,
      "filterable" => true,
      "key" => "facet_key",
      "name" => "Facet Name",
      "preposition" => "with",
      "nested_facet" => true,
      "sub_facet_key" => "sub_facet_key",
      "sub_facet_name" => "Sub Facet Name",
      "type" => "nested",
    }
  end
  let(:allowed_values) do
    [
      {
        "label" => "Allowed value 1",
        "value" => "allowed-value-1",
        "sub_facets" => [
          {
            "label" => "Sub facet Value 1",
            "value" => "allowed-value-1-sub-facet-value-1",
            "main_facet_label" => "Allowed value 1",
            "main_facet_value" => "allowed-value-1",
          },
          {
            "label" => "Sub facet Value 2",
            "value" => "allowed-value-1-sub-facet-value-2",
            "main_facet_label" => "Allowed value 1",
            "main_facet_value" => "allowed-value-1",
          },
        ],
      },
      {
        "label" => "Allowed value 2",
        "value" => "allowed-value-2",
        "sub_facets" => [
          {
            "label" => "Sub facet Value 1",
            "value" => "allowed-value-2-sub-facet-value-1",
            "main_facet_label" => "Allowed value 2",
            "main_facet_value" => "allowed-value-2",
          },
        ],
      },
      {
        "label" => "Allowed value 3",
        "value" => "allowed-value-3",
      },
    ]
  end
  let(:value_hash) { {} }

  describe "facet options" do
    it "returns main facet options" do
      expect(subject.main_facet_options).to eq(
        [
          {
            "text": "All facet names",
            "value": "",
          },
          {
            "text": "Allowed value 1",
            "value": "allowed-value-1",
            "selected": false,
          },
          {
            "text": "Allowed value 2",
            "value": "allowed-value-2",
            "selected": false,
          },
          {
            "text": "Allowed value 3",
            "value": "allowed-value-3",
            "selected": false,
          },
        ],
      )
    end

    it "returns sub-facet options" do
      expect(subject.sub_facet_options).to eq(
        [
          {
            "text": "All sub facet names",
            "value": "",
          },
          {
            text: "Allowed value 1 - Sub facet Value 1",
            value: "allowed-value-1-sub-facet-value-1",
            "selected": false,
            "data_attributes":
              {
                "main_facet_label": "Allowed value 1",
                "main_facet_value": "allowed-value-1",
              },
          },
          {
            text: "Allowed value 1 - Sub facet Value 2",
            value: "allowed-value-1-sub-facet-value-2",
            "selected": false,
            "data_attributes":
              {
                "main_facet_label": "Allowed value 1",
                "main_facet_value": "allowed-value-1",
              },
          },
          {
            text: "Allowed value 2 - Sub facet Value 1",
            value: "allowed-value-2-sub-facet-value-1",
            "selected": false,
            "data_attributes":
              {
                "main_facet_label": "Allowed value 2",
                "main_facet_value": "allowed-value-2",
              },
          },
        ],
      )
    end

    context "when there is a selection" do
      let(:allowed_values) do
        [
          {
            "label" => "Allowed value 1",
            "value" => "allowed-value-1",
            "sub_facets" => [
              {
                "label" => "Sub facet Value 1",
                "value" => "allowed-value-1-sub-facet-value-1",
                "main_facet_label" => "Allowed value 1",
                "main_facet_value" => "allowed-value-1",
              },
            ],
          },
        ]
      end
      let(:value_hash) do
        { "facet_key" => "allowed-value-1", "sub_facet_key" => "allowed-value-1-sub-facet-value-1" }
      end

      it "returns `selected` flag for each option" do
        expect(subject.main_facet_options).to eq(
          [
            {
              "text": "All facet names",
              "value": "",
            },
            {
              "text": "Allowed value 1",
              "value": "allowed-value-1",
              "selected": true,
            },
          ],
        )

        expect(subject.sub_facet_options).to eq(
          [
            {
              "text": "All sub facet names",
              "value": "",
            },
            {
              text: "Allowed value 1 - Sub facet Value 1",
              value: "allowed-value-1-sub-facet-value-1",
              "selected": true,
              "data_attributes":
                {
                  "main_facet_label": "Allowed value 1",
                  "main_facet_value": "allowed-value-1",
                },
            },
          ],
        )
      end
    end
  end

  describe "#sentence_fragment" do
    context "allowed value selected" do
      let(:value_hash) do
        { "facet_key" => "allowed-value-1", "sub_facet_key" => "allowed-value-1-sub-facet-value-1" }
      end

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("with")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("facet_key")
      end
    end

    context "disallowed value selected" do
      let(:value_hash) do
        {
          "facet_key" => "disallowed-value-1",
          "sub_facet_key" => "disallowed-value-2",
        }
      end

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#applied_filters" do
    context "only main facet selected" do
      let(:value_hash) do
        {
          "facet_key" => "allowed-value-1",
        }
      end

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Facet Name",
            label: "Allowed value 1",
            query_params: {
              "facet_key" => "allowed-value-1",
            },
          },
        ])
      end
    end

    context "both main and sub-facet selected" do
      let(:value_hash) do
        {
          "facet_key" => "allowed-value-1",
          "sub_facet_key" => "allowed-value-1-sub-facet-value-1",
        }
      end

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Facet Name",
            label: "Allowed value 1",
            query_params: {
              "facet_key" => "allowed-value-1",
              "sub_facet_key" => "allowed-value-1-sub-facet-value-1",
            },
          },
          {
            name: "Sub Facet Name",
            label: "Allowed value 1 - Sub facet Value 1",
            query_params: {
              "sub_facet_key" => "allowed-value-1-sub-facet-value-1",
            },
          },
        ])
      end
    end

    context "disallowed value selected" do
      let(:value_hash) do
        {
          "facet_key" => "disallowed-value-1",
          "sub_facet_key" => "disallowed-value-2",
        }
      end

      specify { expect(subject.applied_filters).to be_empty }
    end
  end
end
