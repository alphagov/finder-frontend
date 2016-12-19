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
        subject.sentence_fragment.preposition.should eql("of value")
        subject.sentence_fragment.values.first.label.should eql("Open")
        subject.sentence_fragment.values.first.parameter_key.should eql("end_date")
      }
    end

    context "multiple values" do
      let(:value) { %w(open closed) }

      specify {
        subject.sentence_fragment.preposition.should eql("of value")
        subject.sentence_fragment.values.first.label.should eql("Open")
        subject.sentence_fragment.values.first.parameter_key.should eql("end_date")

        subject.sentence_fragment.values.last.label.should eql("Closed")
        subject.sentence_fragment.values.last.parameter_key.should eql("end_date")
      }
    end

    context "disallowed values" do
      let(:value) { %w(disallowed-value-1 disallowed-value-2) }
      specify { subject.sentence_fragment.should be_nil }
    end
  end
end
