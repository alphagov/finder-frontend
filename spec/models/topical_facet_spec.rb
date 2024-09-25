require "spec_helper"

describe TopicalFacet do
  let(:facet_data) do
    {
      "type" => "topical",
      "name" => "State",
      "key" => "end_date",
      "preposition" => "of value",
      "open_value" => {
        "label" => "Open",
        "value" => "open",
      },
      "closed_value" => {
        "label" => "Closed",
        "value" => "closed",
      },
    }
  end

  describe "#sentence_fragment" do
    context "single value" do
      subject { described_class.new(facet_data, value) }

      let(:value) { %w[open] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Open")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("end_date")
      end
    end

    context "multiple values" do
      subject { described_class.new(facet_data, value) }

      let(:value) { %w[open closed] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Open")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("end_date")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Closed")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("end_date")
      end
    end

    context "disallowed values" do
      subject { described_class.new(facet_data, value) }

      let(:value) { %w[disallowed-value-1 disallowed-value-2] }

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
