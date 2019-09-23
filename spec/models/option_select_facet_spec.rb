require "spec_helper"

describe OptionSelectFacet do
  let(:allowed_values) {
    [
      {
        "label" => "Allowed value 1",
        "value" => "allowed-value-1",
      },
      {
        "label" => "Allowed value 2",
        "value" => "allowed-value-2",
      },
      {
        "label" => "Remittals",
        "value" => "remittals",
      },
    ]
  }

  let(:facet_data) {
    {
      "type" => "multi-select",
      "name" => "Test values",
      "key" => "test_values",
      "preposition" => "of value",
      "allowed_values" => allowed_values,
    }
  }


  describe "#sentence_fragment" do
    context "single value" do
      subject { OptionSelectFacet.new(facet_data, %w[allowed-value-1]) }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")
      }
    end

    context "multiple values" do
      subject { OptionSelectFacet.new(facet_data, %w[allowed-value-1 allowed-value-2]) }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Allowed value 2")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("test_values")
      }
    end

    context "disallowed values" do
      subject { OptionSelectFacet.new(facet_data, ["disallowed-value-1, disallowed-value-2"]) }
      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#query_params" do
    context "value selected" do
      subject { OptionSelectFacet.new(facet_data, "allowed-value-1") }
      specify {
        expect(subject.query_params).to eql("test_values" => %w[allowed-value-1])
      }
    end
  end

  describe "#unselected?" do
    subject { OptionSelectFacet.new(facet_data, ["disallowed-value-1, disallowed-value-2"]) }

    context "no selected values" do
      specify { expect(subject.unselected?).to be true }
    end

    context "some selected values" do
      let(:facet_data) {
        {
          "type" => "multi-select",
          "name" => "Test values",
          "key" => "test_values",
          "preposition" => "of value",
          "allowed_values" => [{ "label" => "One", "value" => "1" }],
        }
      }

      subject { OptionSelectFacet.new(facet_data, "1") }

      specify do
        expect(subject.unselected?).to be false
      end
    end
  end
end
