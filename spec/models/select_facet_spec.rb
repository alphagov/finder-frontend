require "spec_helper"

describe SelectFacet do
  subject { SelectFacet.new }

  describe ".from_hash" do
    let(:facet_hash) { {
      "name" => "Case type",
      "key" => "case_type",
      "allowed_values" => [
        { "label" => "Airport price control reviews", "value" => "airport-price-control-reviews" },
        { "label" => "Market investigations",         "value" => "market-investigations" },
        { "label" => "Remittals",                     "value" => "remittals" }
      ],
      "include_blank" => "All case types"
    } }
    subject { SelectFacet.from_hash(facet_hash) }

    specify { subject.name.should == "Case type" }
    specify { subject.key.should == "case_type" }
    specify { subject.include_blank.should == "All case types" }

    it "should build a list of allowed values" do
      subject.allowed_values[0].label.should == "Airport price control reviews"
      subject.allowed_values[0].value.should == "airport-price-control-reviews"
      subject.allowed_values[2].label.should == "Remittals"
      subject.allowed_values[2].value.should == "remittals"
    end
  end

  describe "#value" do
    let(:allowed_values) { [ OpenStruct.new(label: "Allowed value", value: "allowed-value") ] }
    let(:value) { nil }
    subject { SelectFacet.new(value: value, allowed_values: allowed_values) }

    context "value is allowed" do
      let(:value) { "allowed-value" }
      specify { subject.value.should == "allowed-value" }
    end

    context "value is not allowed" do
      let(:value) { "not-allowed-value" }
      specify { subject.value.should be_nil }
    end
  end

  describe "#values_for_select" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Airport price control reviews", value: "airport-price-control-reviews"),
      OpenStruct.new(label: "Market investigations", value: "market-investigations"),
      OpenStruct.new(label: "Remittals", value: "remittals")
    ] }
    let(:include_blank) { '' }
    subject { SelectFacet.new(include_blank: include_blank, allowed_values: allowed_values) }

    context "with a blank value for include_blank" do
      let(:include_blank) { '' }

      it "should return allowed values in a format accepted by options_for_select" do
        subject.values_for_select.should == [
          ['Airport price control reviews', 'airport-price-control-reviews'],
          ['Market investigations', 'market-investigations'],
          ['Remittals', 'remittals']
        ]
      end
    end

    context "with a non-empty string for include_blank" do
      let(:include_blank) { 'All case types' }

      it "should return allowed values in a format accepted by options_for_select" do
        subject.values_for_select.should == [
          ['All case types', nil],
          ['Airport price control reviews', 'airport-price-control-reviews'],
          ['Market investigations', 'market-investigations'],
          ['Remittals', 'remittals']
        ]
      end
    end
  end
end
