require "spec_helper"

describe SelectFacet do
  let(:allowed_values) {
    [
      {
        'label' => "Allowed value 1",
        'value' => "allowed-value-1"
      },
      {
        'label' => "Allowed value 2",
        'value' => "allowed-value-2"
      },
      {
        'label' => "Remittals",
        'value' => "remittals"
      }
    ]
  }

  let(:facet_data) {
    {
      'type' => "multi-select",
      'name' => "Test values",
      'key' => "test_values",
      'preposition' => "of value",
      'allowed_values' => allowed_values,
    }
  }

  subject { SelectFacet.new(facet_data) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { ["allowed-value-1"] }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Allowed value 1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("test_values")
      }
    end

    context "multiple values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Allowed value 1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("test_values")

        expect(subject.sentence_fragment['values'].last['label']).to eql("Allowed value 2")
        expect(subject.sentence_fragment['values'].last['parameter_key']).to eql("test_values")
      }
    end

    context "disallowed values" do
      let(:value) { ["disallowed-value-1, disallowed-value-2"] }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
