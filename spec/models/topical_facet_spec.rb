require "spec_helper"

describe TopicalFacet do
  let(:facet_data) {
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
  }


  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { %w(open) }
      subject { TopicalFacet.new(facet_data, value) }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Open")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("end_date")
      }
    end

    context "multiple values" do
      let(:value) { %w(open closed) }
      subject { TopicalFacet.new(facet_data, value) }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Open")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("end_date")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Closed")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("end_date")
      }
    end

    context "disallowed values" do
      let(:value) { %w(disallowed-value-1 disallowed-value-2) }
      subject { TopicalFacet.new(facet_data, value) }

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end
end
