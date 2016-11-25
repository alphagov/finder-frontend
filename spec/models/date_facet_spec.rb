require "spec_helper"

describe DateFacet do
  let(:facet_struct) {
    OpenStruct.new(
      type: "date",
      name: "Occurred",
      key: "date_of_occurrence",
      preposition: "occurred",
    )
  }

  subject { DateFacet.new(facet_struct) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do

    let(:value) { nil }

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }
      specify {
        subject.sentence_fragment.preposition.should == "occurred after"
        subject.sentence_fragment.values.first.label == "22 September 1988"
        subject.sentence_fragment.values.first.parameter_key == "date_of_occurrence[from]"
      }
    end

    context "6 digit date value" do
      let(:value) { { to: "22/09/14" } }
      specify {
        subject.sentence_fragment.preposition.should == "occurred before"
        subject.sentence_fragment.values.first.label == "22 September 2014"
        subject.sentence_fragment.values.first.parameter_key == "date_of_occurrence[to]"
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
        subject.sentence_fragment.preposition.should == "occurred between"

        subject.sentence_fragment.values.first.label == "22 September 1988"
        subject.sentence_fragment.values.first.parameter_key == "date_of_occurrence[to]"

        subject.sentence_fragment.values.last.label == "22 September 2014"
        subject.sentence_fragment.values.last.parameter_key == "date_of_occurrence[from]"
      }
    end
  end
end
