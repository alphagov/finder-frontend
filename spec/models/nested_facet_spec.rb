require "spec_helper"

describe NestedFacet do
  subject { described_class.new(facet_hash, value_hash) }

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
      "type" => "text",
      "name" => "Facet Name",
      "key" => "facet_key",
      "preposition" => "with",
      "allowed_values" => allowed_values,
    }
  end
  let(:value_hash) { {} }

  describe "#facet_options" do
    it "returns text and value pairs for the parent values" do
      expect(subject.facet_options).to eq(
        [{
          text: "All facet names",
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
end
