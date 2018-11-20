require "spec_helper"

describe CheckboxFacet do
  let(:checkboxes) {
    [
      {
        'label' => "Allowed value 1",
        'checkbox_label' => "Show allowed value 1",
        'value' => "allowed-value-1"
      },
      {
        'label' => "Allowed value 2",
        'checkbox_label' => "Show allowed value 2",
        'value' => "allowed-value-2"
      },
      {
        'label' => "Remittals",
        'checkbox_label' => "Show allowed value 3",
        'value' => "remittals"
      }
    ]
  }

  let(:facet_data) {
    {
      'type' => "checkbox",
      'key' => "test_values",
      'preposition' => "of value",
      'checkboxes' => checkboxes,
    }
  }

  let(:checkbox) {
    Checkbox.new(checkboxes.first)
  }

  subject { CheckboxFacet.new(facet_data) }

  describe "#sentence_fragment" do
    before do
      subject.value = value
    end

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

  describe "#checked?" do
    before do
      subject.value = value
    end

    context "checkbox is selected" do
      let(:value) { %w(allowed-value-1) }
      specify {
        expect(subject.checked?(checkbox)).to eql(true)
      }
    end

    context "checkbox is not selected" do
      let(:value) { [] }
      specify {
        expect(subject.checked?(checkbox)).to eql(false)
      }
    end

    context "another checkbox is selected" do
      let(:value) { %w(allowed-value-2) }
      specify {
        expect(subject.checked?(checkbox)).to eql(false)
      }
    end
  end
end
