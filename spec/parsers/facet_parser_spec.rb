require "spec_helper"

describe FacetParser do
  context "with a select facet definition" do
    let(:facet_definition) {
      {
        "type" => "text",
        "filterable" => true,
        "display_as_result_metadata" => true,
        "name" => "Case type",
        "key" => "case_type",
        "preposition" => "of type",
        "allowed_values" => [
          {
            "label" => "Airport price control reviews",
            "value" => "airport-price-control-reviews",
          },
          {
            "label" => "Market investigations",
            "value" => "market-investigations",
          },
          {
            "label" => "Remittals",
            "value" => "remittals",
          },
        ],
      }
    }
    subject { FacetParser.parse(facet_definition, {}) }

    specify { expect(subject).to be_a OptionSelectFacet }
    specify { expect(subject.name).to eql("Case type") }
    specify { expect(subject.key).to eql("case_type") }
    specify { expect(subject.preposition).to eql("of type") }

    it "should build a list of allowed values" do
      expect(subject.allowed_values[0]["label"]).to eql("Airport price control reviews")
      expect(subject.allowed_values[0]["value"]).to eql("airport-price-control-reviews")
      expect(subject.allowed_values[2]["label"]).to eql("Remittals")
      expect(subject.allowed_values[2]["value"]).to eql("remittals")
    end
  end
end
