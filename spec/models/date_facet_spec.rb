require "spec_helper"

describe DateFacet do
  subject { described_class.new(facet_data, value) }

  let(:facet_data) do
    {
      "type" => "date",
      "name" => "Occurred",
      "key" => "date_of_occurrence",
      "preposition" => "occurred",
    }
  end
  let(:value) { nil }

  it { is_expected.to be_user_visible }

  describe "#sentence_fragment" do
    context "single date value" do
      let(:value) { { from: "22/09/1988" } }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("occurred after")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("22 September 1988")
        expect(subject.sentence_fragment["key"]).to eql("date_of_occurrence")
      end
    end

    context "6 digit date value" do
      let(:value) { { to: "22/09/14" } }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("occurred before")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("22 September 2014")
        expect(subject.sentence_fragment["key"]).to eql("date_of_occurrence")
      end
    end

    context "multiple date values" do
      let(:value) do
        {
          "from" => "22/09/1988",
          "to" => "22/09/2014",
        }
      end

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("occurred between")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("22 September 1988")
        expect(subject.sentence_fragment["values"].last["label"]).to eql("22 September 2014")
        expect(subject.sentence_fragment["key"]).to eql("date_of_occurrence")
      end
    end
  end

  describe "#applied_filters" do
    context "no value" do
      let(:value) { nil }

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([])
      end
    end

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([{
          name: "Occurred after",
          label: "22 September 1988",
          query_params: { "date_of_occurrence" => { from: "22/09/1988" } },
        }])
      end
    end

    context "multiple date values" do
      let(:value) do
        {
          from: "22/09/1988",
          to: "22/09/2014",
        }
      end

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Occurred after",
            label: "22 September 1988",
            query_params: { "date_of_occurrence" => { from: "22/09/1988" } },
          },
          {
            name: "Occurred before",
            label: "22 September 2014",
            query_params: { "date_of_occurrence" => { to: "22/09/2014" } },
          },
        ])
      end
    end
  end

  describe "#query_params" do
    context "multiple date values" do
      let(:value) do
        {
          "from" => "22/09/1988",
          "to" => "22/09/2014",
        }
      end

      specify do
        expect(subject.query_params).to eql(
          "date_of_occurrence" =>
            { "from" => "22/09/1988",
              "to" => "22/09/2014" },
        )
      end
    end
  end
end
