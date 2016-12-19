require 'spec_helper'

describe FacetParser do
  context "with a select facet OpenStruct" do
    let(:facet) {
      OpenStruct.new(
        type: "text",
        filterable: true,
        display_as_result_metadata: true,
        name: "Case type",
        key: "case_type",
        preposition: "of type",
        allowed_values: [
          OpenStruct.new(
            label: "Airport price control reviews",
            value: "airport-price-control-reviews"
          ),
          OpenStruct.new(
            label: "Market investigations",
            value: "market-investigations"
          ),
          OpenStruct.new(
            label: "Remittals",
            value: "remittals"
          )
        ],
      )
    }
    subject { FacetParser.parse(facet) }

    specify { subject.should be_a SelectFacet }
    specify { subject.name.should eql("Case type") }
    specify { subject.key.should eql("case_type") }
    specify { subject.preposition.should eql("of type") }

    it "should build a list of allowed values" do
      subject.allowed_values[0].label.should eql("Airport price control reviews")
      subject.allowed_values[0].value.should eql("airport-price-control-reviews")
      subject.allowed_values[2].label.should eql("Remittals")
      subject.allowed_values[2].value.should eql("remittals")
    end
  end
end
