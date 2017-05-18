require "spec_helper"

describe TopicalFacet do
  let(:facet_struct) {
    open = OpenStruct.new(
      label: "Open",
      value: "open"
    )

    closed = OpenStruct.new(
      label: "Closed",
      value: "closed"
    )

    OpenStruct.new(
      type: "topical",
      name: "State",
      key: "end_date",
      preposition: "of value",
      open_value: open,
      closed_value: closed
    )
  }

  subject { TopicalFacet.new(facet_struct) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { %w(open) }

      specify {
        expect(subject.sentence_fragment.preposition).to eql("of value")
        expect(subject.sentence_fragment.values.first.label).to eql("Open")
        expect(subject.sentence_fragment.values.first.parameter_key).to eql("end_date")
      }
    end

    context "multiple values" do
      let(:value) { %w(open closed) }

      specify {
        expect(subject.sentence_fragment.preposition).to eql("of value")
        expect(subject.sentence_fragment.values.first.label).to eql("Open")
        expect(subject.sentence_fragment.values.first.parameter_key).to eql("end_date")

        expect(subject.sentence_fragment.values.last.label).to eql("Closed")
        expect(subject.sentence_fragment.values.last.parameter_key).to eql("end_date")
      }
    end

    context "disallowed values" do
      let(:value) { %w(disallowed-value-1 disallowed-value-2) }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
