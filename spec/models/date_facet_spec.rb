require "spec_helper"

describe DateFacet do
  let(:facet_data) {
    {
      'type' => "date",
      'name' => "Occurred",
      'key' => "date_of_occurrence",
      'preposition' => "occurred",
    }
  }

  subject { DateFacet.new(facet_data) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do
    let(:value) { nil }

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }
      specify {
        expect(subject.sentence_fragment.preposition).to eql("occurred after")
        expect(subject.sentence_fragment.values.first.label).to eql("22 September 1988")
        expect(subject.sentence_fragment.values.first.parameter_key).to eql("date_of_occurrence")
      }
    end

    context "6 digit date value" do
      let(:value) { { to: "22/09/14" } }
      specify {
        expect(subject.sentence_fragment.preposition).to eql("occurred before")
        expect(subject.sentence_fragment.values.first.label).to eql("22 September 2014")
        expect(subject.sentence_fragment.values.first.parameter_key).to eql("date_of_occurrence")
      }
    end

    context "multiple date values" do
      let(:value) {
        {
          "from" => "22/09/1988",
          "to" => "22/09/2014",
        }
      }
      specify {
        expect(subject.sentence_fragment.preposition).to eql("occurred between")

        expect(subject.sentence_fragment.values.first.label).to eql("22 September 1988")
        expect(subject.sentence_fragment.values.first.parameter_key).to eql("date_of_occurrence")

        expect(subject.sentence_fragment.values.last.label).to eql("22 September 2014")
        expect(subject.sentence_fragment.values.last.parameter_key).to eql("date_of_occurrence")
      }
    end
  end
end
