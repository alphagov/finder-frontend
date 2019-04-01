require 'spec_helper'

describe HiddenClearableFacet do
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
            'label' => "Allowed value 3",
            'value' => "allowed-value-3"
        }
    ]
  }

  let(:facet_data) {
    {
      'key' => "test_facet",
      'name' => "Test facet",
      'preposition' => "of value",
      'allowed_values' => allowed_values
    }
  }

  let(:facet_class) { HiddenClearableFacet }
  subject { facet_class.new(facet_data) }


  describe "#sentence_fragment" do
    before do
      subject.value = value
    end

    context "single value" do
      let(:value) { ["allowed-value-1"] }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Allowed value 1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("test_facet")
      }
    end

    context "multiple values" do
      let(:value) { ["allowed-value-1", "allowed-value-2"] }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Allowed value 1")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("test_facet")

        expect(subject.sentence_fragment['values'].last['label']).to eql("Allowed value 2")
        expect(subject.sentence_fragment['values'].last['parameter_key']).to eql("test_facet")
      }
    end

    context "disallowed values" do
      let(:value) { ["disallowed-value-1, disallowed-value-2"] }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#has_filters?" do
    before do
      subject.value = value
    end

    context "no value" do
      let(:value) { nil }

      specify {
        expect(subject.has_filters?).to eql(false)
      }
    end

    context "has a value" do
      let(:value) { ["allowed-value-1"] }

      specify {
        expect(subject.has_filters?).to eql(true)
      }
    end
  end
end
