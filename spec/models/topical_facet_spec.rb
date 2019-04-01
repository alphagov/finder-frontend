require "spec_helper"

describe TopicalFacet do
  let(:facet_data) {
    {
      'type' => "topical",
      'name' => "State",
      'key' => "end_date",
      'preposition' => "of value",
      'open_value' => {
        'label' => "Open",
        'value' => "open"
      },
      'closed_value' => {
        'label' => "Closed",
        'value' => "closed"
      }
    }
  }

  subject { TopicalFacet.new(facet_data) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { %w(open) }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Open")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("end_date")
      }
    end

    context "multiple values" do
      let(:value) { %w(open closed) }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Open")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("end_date")

        expect(subject.sentence_fragment['values'].last['label']).to eql("Closed")
        expect(subject.sentence_fragment['values'].last['parameter_key']).to eql("end_date")
      }
    end

    context "disallowed values" do
      let(:value) { %w(disallowed-value-1 disallowed-value-2) }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#has_value?" do
    context "value is empty" do
      subject { TopicalFacet.new(facet_data, []) }

      specify do
        expect(subject.has_value?).to be false
      end
    end

    context "value is nil" do
      subject { TopicalFacet.new(facet_data, nil) }

      specify do
        expect(subject.has_value?).to be false
      end
    end

    context "value has entries" do
      subject { TopicalFacet.new(facet_data, %w(allowed-value-1 allowed-value-2)) }

      specify do
        expect(subject.has_value?).to be true
      end
    end
  end
end
