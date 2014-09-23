require "spec_helper"

describe DateFacet do
  subject { DateFacet.new }

  describe "#value" do

    let(:value) { nil }
    subject { DateFacet.new(value: value) }

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }
      specify { subject.value.should == "from:1988-09-22" }
    end

    context "multiple date values" do
      let(:value) {
        {
          from: "22/09/1988",
          to: "22/09/2014",
        }
      }
      specify { subject.value.should == "from:1988-09-22,to:2014-09-22" }
    end

    context "non-date values" do
      let(:value) {
        {
          from: "zig",
          to: "zag",
        }
      }
      specify { subject.value.should == "" }
    end

    context "mix of date and non-date values" do
      let(:value) {
        {
          from: "22/09/1988",
          to: "zag",
        }
      }
      specify { subject.value.should == "from:1988-09-22" }
    end
  end

  describe "#sentence_fragment" do

    let(:value) { nil }
    subject { 
      DateFacet.new(
        value: value,
        preposition: "occurred",
        key: "date_of_occurrence"
      )
    }

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }
      specify {
        subject.sentence_fragment.preposition.should == "occurred after"
        subject.sentence_fragment.values.first.label == "22 September 1988"
        subject.sentence_fragment.values.first.parameter_key == "date_of_occurrence[from]"
        subject.sentence_fragment.values.first.other_params == []
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
        subject.sentence_fragment.values.first.other_params == ["to","22/09/2014"]

        subject.sentence_fragment.values.last.label == "22 September 2014"
        subject.sentence_fragment.values.last.parameter_key == "date_of_occurrence[from]"
        subject.sentence_fragment.values.last.other_params == ["from","22/09/1988"]
      }
    end
  end
end
