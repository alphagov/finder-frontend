require "rails_helper"

describe SelectFacet do
  subject { SelectFacet.new }

  describe "#value" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Allowed value 1", value: "allowed-value-1", described: true),
      OpenStruct.new(label: "Allowed value 2", value: "allowed-value-2", described: true)
    ] }

    let(:value) { nil }
    subject { SelectFacet.new(value: value, allowed_values: allowed_values) }

    context "single permitted value" do
      let(:value) { ["allowed-value-1"] }
      specify { subject.value.should == ["allowed-value-1"] }
    end

    context "multiple permitted values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }
      specify { subject.value.should == ["allowed-value-1", "allowed-value-2"] }
    end

    context "single disallowed value" do
      let(:value) { ["not-allowed-value"] }
      specify { subject.value.should == [] }
    end

    context "mix of permitted and disallowed values" do
      let(:value) { ["allowed-value-1", "not-allowed-value"] }
      specify { subject.value.should == ["allowed-value-1"] }
    end
  end

  describe "#values_for_select" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Airport price control reviews", value: "airport-price-control-reviews", described: true),
      OpenStruct.new(label: "Market investigations",         value: "market-investigations",         described: true),
      OpenStruct.new(label: "Remittals",                     value: "remittals",                     described: true)
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

  describe "#selected_values" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Allowed value 1", value: "allowed-value-1", described: true),
      OpenStruct.new(label: "Allowed value 2", value: "allowed-value-2", described: true),
      OpenStruct.new(label: "Allowed value 3", value: "allowed-value-3", described: false)
    ] }

    let(:value) { nil }
    subject { SelectFacet.new(value: value, allowed_values: allowed_values) }

    context "permitted value" do
      let(:value) { ["allowed-value-1"] }

      it "should return selected value object" do
        subject.selected_values.length.should == 1
        subject.selected_values[0].should == allowed_values[0]
      end
    end

    context "multiple permitted values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      it "should return selected value object" do
        subject.selected_values.length.should == 2
        subject.selected_values[0].should == allowed_values[0]
        subject.selected_values[1].should == allowed_values[1]
      end
    end

    context "permitted non described value" do
      let(:value) { ["allowed-value-3"] }

      it "should return no value objects" do
        subject.selected_values.should == []
      end
    end

    context "non-permitted value" do
      let(:value) { ["non-allowed-value-1"] }

      it "should return no value objects" do
        subject.selected_values.should == []
      end
    end
  end

  describe "#sentence_fragment" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Allowed value 1", value: "allowed-value-1", described: true),
      OpenStruct.new(label: "Allowed value 2", value: "allowed-value-2", described: true),
      OpenStruct.new(label: "Allowed value 3", value: "allowed-value-3", described: false)
    ] }

    let(:value) { nil }
    subject {
      SelectFacet.new(
        value: value,
        allowed_values: allowed_values,
        preposition: "of value",
        key: "test_values"
      )
    }

    context "single value" do
      let(:value) { ["allowed-value-1"] }

      specify {
        subject.sentence_fragment.preposition.should == "of value"
        subject.sentence_fragment.values.first.label == "Allowed value 1"
        subject.sentence_fragment.values.first.parameter_key == "test_values"
        subject.sentence_fragment.values.first.other_params == []
      }
    end

    context "multiple values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      specify {
        subject.sentence_fragment.preposition.should == "of value"
        subject.sentence_fragment.values.first.label == "Allowed value 1"
        subject.sentence_fragment.values.first.parameter_key == "test_values"
        subject.sentence_fragment.values.first.other_params == ["allowed-value-2"]

        subject.sentence_fragment.values.last.label == "Allowed value 2"
        subject.sentence_fragment.values.last.parameter_key == "test_values"
        subject.sentence_fragment.values.last.other_params == ["allowed-value-1"]
      }
    end
  end
end
