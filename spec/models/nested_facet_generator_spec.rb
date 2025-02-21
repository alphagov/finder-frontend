require "spec_helper"

describe NestedFacetGenerator do
  subject { described_class.new(facet_hash, value_hash) }

  let(:allowed_values) do
    [
      {
        "label" => "Allowed value 1",
        "value" => "allowed-value-1",
        "sub_facets" => [
          {
            "label" => "Allowed value 1 Sub facet Value 1",
            "value" => "allowed-value-1-sub-facet-value-1",
          },
          {
            "label" => "Allowed value 1 Sub facet Value 2",
            "value" => "allowed-value-1-sub-facet-value-2",
          },
        ],
      },
      {
        "label" => "Allowed value 2",
        "value" => "allowed-value-2",
        "sub_facets" => [
          {
            "label" => "Allowed value 2 Sub facet Value 1",
            "value" => "allowed-value-2-sub-facet-value-1",
          },
        ],
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
      "sub_facet_key" => "test_sub_facet_key",
      "sub_facet_name" => "Test Sub Facet Name",
      "nested_facet" => true,
    }
  end
  let(:value_hash) { {} }

  describe "#generate_facets" do
    let(:main_facet_hash) do
      {
        "type" => "text",
        "name" => "Facet Name",
        "key" => "facet_key",
        "preposition" => "with",
        "allowed_values" => [
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
        ],
      }
    end

    let(:sub_facet_hash) do
      {
        "allowed_values" => [
          { "label" => "Allowed value 1 Sub facet Value 1",
            "value" => "allowed-value-1-sub-facet-value-1",
            "main_facet_value" => "allowed-value-1" },
          { "label" => "Allowed value 1 Sub facet Value 2",
            "value" => "allowed-value-1-sub-facet-value-2",
            "main_facet_value" => "allowed-value-1" },
          { "label" => "Allowed value 2 Sub facet Value 1",
            "value" => "allowed-value-2-sub-facet-value-1",
            "main_facet_value" => "allowed-value-2" },
        ],
        "filterable" => true,
        "key" => "test_sub_facet_key",
        "name" => "Test Sub Facet Name",
        "type" => "text",
        "preposition" => "with",
      }
    end

    it "generates main and sub facets" do
      expect(NestedFacet).to receive(:new).with(main_facet_hash, nil)
      expect(NestedFacet).to receive(:new).with(sub_facet_hash, nil)

      subject.generate_facets
    end
  end
end
