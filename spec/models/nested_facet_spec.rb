require "spec_helper"

describe NestedFacet do
  subject { described_class.new(facet_hash, values) }
  let(:values) { {} }

  describe "#facet_options" do
    context "when the facet is a main facet" do
      let(:allowed_values) do
        [
          {
            "label" => "Allowed value 1",
            "value" => "allowed-value-1",
          },
          {
            "label" => "Allowed value 2",
            "value" => "allowed-value-2",
          },
          {
            "label" => "Allowed value 3",
            "value" => "allowed-value-3",
          },
        ]
      end
      let(:facet_hash) do
        {
          "allowed_values" => allowed_values,
          "filterable" => true,
          "key" => "sub_facet_key",
          "name" => "Facet Name",
          "preposition" => "with",
          "nested_facet" => true,
          "sub_facet_key" => "some_sub_facet_key",
          "sub_facet_name" => "Some sub facet key",
          "type" => "text",
        }
      end

      it "returns text and value pairs" do
        expect(subject.facet_options).to eq(
          [{
            "text": "All facet names",
            "value": "",
          },
           {
             "text": "Allowed value 1",
             "value": "allowed-value-1",
           },
           {
             "text": "Allowed value 2",
             "value": "allowed-value-2",
           },
           {
             "text": "Allowed value 3",
             "value": "allowed-value-3",
           }],
        )
      end
    end

    context "when the facet is a sub facet" do
      let(:facet_hash) do
        {
          "allowed_values" => allowed_values,
          "filterable" => true,
          "key" => "sub_facet_key",
          "name" => "Sub Facet Name",
          "nested_facet" => true,
          "preposition" => "with",
          "type" => "text",
        }
      end
      let(:allowed_values) do
        [
          {
            "label" => "Allowed value 1 Sub facet Value 1",
            "value" => "allowed-value-1-sub-facet-value-1",
            "main_facet_label" => "Allowed value 1",
            "main_facet_value" => "allowed-value-1",
          },
          {
            "label" => "Allowed value 1 Sub facet Value 2",
            "value" => "allowed-value-1-sub-facet-value-2",
            "main_facet_label" => "Allowed value 1",
            "main_facet_value" => "allowed-value-1",
          },
          {
            "label" => "Allowed value 2 Sub facet Value 1",
            "value" => "allowed-value-2-sub-facet-value-1",
            "main_facet_label" => "Allowed value 2",
            "main_facet_value" => "allowed-value-2",
          },
        ]
      end

      it "returns text, value and main data attributes" do
        expect(subject.facet_options).to eq(
          [
            {
              "text": "All sub facet names",
              "value": "",
            },
            {
              text: "Allowed value 1 - Allowed value 1 Sub facet Value 1",
              value: "allowed-value-1-sub-facet-value-1",
              "data_attributes":
                {
                  "main_facet_label": "Allowed value 1",
                  "main_facet_value": "allowed-value-1",
                },
            },
            {
              text: "Allowed value 1 - Allowed value 1 Sub facet Value 2",
              value: "allowed-value-1-sub-facet-value-2",
              "data_attributes":
                {
                  "main_facet_label": "Allowed value 1",
                  "main_facet_value": "allowed-value-1",
                },
            },
            {
              text: "Allowed value 2 - Allowed value 2 Sub facet Value 1",
              value: "allowed-value-2-sub-facet-value-1",
              "data_attributes":
                {
                  "main_facet_label": "Allowed value 2",
                  "main_facet_value": "allowed-value-2",
                },
            },
          ],
        )
      end
    end
  end
end
