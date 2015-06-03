require "spec_helper"

describe SelectFacet do
  let(:allowed_values) {
    [
      OpenStruct.new(
        label: "Airport price control reviews",
        value: "allowed-value-1"
      ),
      OpenStruct.new(
        label: "Market investigations",
        value: "allowed-value-2"
      ),
      OpenStruct.new(
        label: "Remittals",
        value: "remittals"
      )
    ]
  }

  let(:facet_struct) {
    OpenStruct.new(
      type: "multi-select",
      name: "Test values",
      key: "test_values",
      preposition: "of value",
      allowed_values: allowed_values,
    )
  }

  subject { SelectFacet.new(facet_struct) }

  before do
    subject.value = value
  end

  describe "#value" do

    context "single permitted value" do
      let(:value) { ["allowed-value-1"] }
      specify { subject.value.should == ["allowed-value-1"] }
    end

    context "multiple permitted values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }
      specify { subject.value.should == ["allowed-value-1", "allowed-value-2"] }
    end

    context "single disallowed value" do
      let(:value) { ["non-allowed-value"] }
      specify { subject.value.should == [] }
    end

    context "mix of permitted and disallowed values" do
      let(:value) { ["allowed-value-1", "not-allowed-value"] }
      specify { subject.value.should == ["allowed-value-1"] }
    end
  end

  describe "#selected_values" do
    context "permitted value" do
      let(:value) { ["allowed-value-1"] }

      it "should return selected value object" do
        subject.selected_values.length.should == 1
        subject.selected_values[0]["label"].should == allowed_values[0].label
        subject.selected_values[0]["value"].should == allowed_values[0].value
      end
    end

    context "multiple permitted values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      it "should return selected value object" do
        subject.selected_values.length.should == 2
        subject.selected_values[0]["label"].should == allowed_values[0].label
        subject.selected_values[0]["value"].should == allowed_values[0].value
        subject.selected_values[1]["label"].should == allowed_values[1].label
        subject.selected_values[1]["value"].should == allowed_values[1].value
      end
    end

    context "non-permitted value" do
      let(:value) { ["non-allowed-value"] }

      it "should return no value objects" do
        subject.selected_values.should == []
      end
    end
  end

  describe "#sentence_fragment" do

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
