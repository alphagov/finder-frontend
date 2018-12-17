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

  describe "#data_attributes" do
    specify {
      expect(subject.data_attributes[:track_category]).to eql('filterClicked')
      expect(subject.data_attributes[:track_action]).to eql('test_values')
    }
  end


  describe "#options" do
    specify {
      expect(subject.options).to eql([["", ""], ["Allowed value 1", "allowed-value-1"], ["Allowed value 2", "allowed-value-2"], %w(Remittals remittals)])
    }
  end

  describe "#selected_options" do
    before do
      subject.value = value
    end

    context "no selected values" do
      let(:value) { [] }
      specify { expect(subject.selected_option).to be_nil }
    end

    context "selected values" do
      let(:value) { %w(allowed-value-1 allowed-value-2) }
      specify { expect(subject.selected_option).to eql(["Allowed value 1", "allowed-value-1"]) }
    end
  end
end
