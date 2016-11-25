require "spec_helper"

describe SelectFacet do
  let(:allowed_values) {
    [
      OpenStruct.new(
        label: "Allowed value 1",
        value: "allowed-value-1"
      ),
       OpenStruct.new(
        label: "Allowed value 2",
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

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { ["allowed-value-1"] }

      specify {
        subject.sentence_fragment.preposition.should == "of value"
        subject.sentence_fragment.values.first.label == "Allowed value 1"
        subject.sentence_fragment.values.first.parameter_key == "test_values"
      }
    end

    context "multiple values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      specify {
        subject.sentence_fragment.preposition.should == "of value"
        subject.sentence_fragment.values.first.label.should == "Allowed value 1"
        subject.sentence_fragment.values.first.parameter_key.should == "test_values"

        subject.sentence_fragment.values.last.label.should == "Allowed value 2"
        subject.sentence_fragment.values.last.parameter_key.should == "test_values"
      }
    end

    context "disallowed values" do
      let(:value) { ["disallowed-value-1, disallowed-value-2"] }
      specify { subject.sentence_fragment.should be_nil }
    end
  end
end
