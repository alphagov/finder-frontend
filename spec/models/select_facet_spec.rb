require "spec_helper"

describe SelectFacet do
  subject { SelectFacet.new }

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
