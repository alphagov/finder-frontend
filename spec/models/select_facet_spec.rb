require "spec_helper"

describe SelectFacet do
  subject { SelectFacet.new(schema, value) }
  let(:schema) { {
    "name" => "Case type",
    "key" => "case_type",
    "allowed_values" => [
      { "label" => "Airport price control reviews", "value" => "airport-price-control-reviews" },
      { "label" => "Market investigations",         "value" => "market-investigations" },
      { "label" => "Remittals",                     "value" => "remittals" }
    ],
    "include_blank" => include_blank
  } }
  let(:value) { }
  let(:include_blank) { "All case types" }

  it "takes allowed values from the schema" do
    subject.allowed_values.map(&:value).should ==
      ["airport-price-control-reviews", "market-investigations", "remittals"]
  end

  context "with an allowed value" do
    let(:value) { "remittals" }
    specify { subject.value.should == "remittals" }
  end

  context "with a non-allowed value" do
    let(:value) { "not-allowed" }
    specify { subject.value.should be_nil }
  end

  describe "#values_for_select" do
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
