require "spec_helper"

describe OptionSelectFacet do
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

  subject { OptionSelectFacet.new(facet_data) }

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

  describe "#close_facet?" do
    context "small number of options" do
      specify { expect(subject.close_facet?).to be false }
    end

    context "large number of options" do
      let(:allowed_values) {
        11.times.map { |i| { 'label' => "Label #{i}", 'value' => "allowed-value-#{i}" } }
      }

      let(:large_facet_data) {
        {
          'type' => "multi-select",
          'name' => "Test values",
          'key' => "test_values",
          'preposition' => "of value",
          'allowed_values' => allowed_values,
        }
      }

      subject { OptionSelectFacet.new(large_facet_data) }

      specify { expect(subject.close_facet?).to be true }
    end
  end

  describe "#unselected?" do
    context "no selected values" do
      specify { expect(subject.unselected?).to be true }
    end

    context "some selected values" do
      let(:facet_data) {
        {
          'type' => "multi-select",
          'name' => "Test values",
          'key' => "test_values",
          'preposition' => "of value",
          'allowed_values' => [{ 'label' => 'One', 'value' => '1' }],
        }
      }

      subject { OptionSelectFacet.new(facet_data) }

      specify do
        subject.value = "1"
        expect(subject.unselected?).to be false
      end
    end
  end

  describe "#has_value?" do
    context "value is empty" do
      subject { OptionSelectFacet.new(facet_data, []) }

      specify do
        expect(subject.has_value?).to be false
      end
    end

    context "value is nil" do
      subject { OptionSelectFacet.new(facet_data, nil) }

      specify do
        expect(subject.has_value?).to be false
      end
    end

    context "value has entries" do
      subject { OptionSelectFacet.new(facet_data, %w(allowed-value-1 allowed-value-2)) }

      specify do
        expect(subject.has_value?).to be true
      end
    end
  end
end
