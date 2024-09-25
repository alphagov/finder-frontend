require "spec_helper"

describe OptionSelectFacet do
  let(:allowed_values) do
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
  end

  let(:facet_data) do
    {
      "type" => "multi-select",
      "name" => "Test values",
      "key" => "test_values",
      "preposition" => "of value",
      "allowed_values" => allowed_values,
    }
  end

  describe "#sentence_fragment" do
    context "single value" do
      subject { described_class.new(facet_data, %w[allowed-value-1]) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")
      end
    end

    context "multiple values" do
      subject { described_class.new(facet_data, %w[allowed-value-1 allowed-value-2]) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Allowed value 2")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("test_values")
      end
    end

    context "disallowed values" do
      subject { described_class.new(facet_data, ["disallowed-value-1, disallowed-value-2"]) }

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#query_params" do
    context "value selected" do
      subject { described_class.new(facet_data, "allowed-value-1") }

      specify do
        expect(subject.query_params).to eql("test_values" => %w[allowed-value-1])
      end
    end
  end

  describe "#unselected?" do
    subject { described_class.new(facet_data, ["disallowed-value-1, disallowed-value-2"]) }

    context "no selected values" do
      specify { expect(subject.unselected?).to be true }
    end

    context "some selected values" do
      subject { described_class.new(facet_data, "1") }

      let(:facet_data) do
        {
          "type" => "multi-select",
          "name" => "Test values",
          "key" => "test_values",
          "preposition" => "of value",
          "allowed_values" => [{ "label" => "One", "value" => "1" }],
        }
      end

      specify do
        expect(subject.unselected?).to be false
      end
    end
  end

  describe "#cache_key" do
    context "where facet allowed values differ in order" do
      let(:allowed_values_2) do
        [
          {
            "label" => "Allowed value 2",
            "value" => "allowed-value-2",
          },
          {
            "label" => "Allowed value 1",
            "value" => "allowed-value-1",
          },
          {
            "label" => "Remittals",
            "value" => "remittals",
          },
        ]
      end

      specify "cache keys should differ" do
        f1 = described_class.new(facet_data, "1")
        f2 = described_class.new(facet_data.merge({ "allowed_values" => allowed_values_2 }), "1")
        expect(f1.cache_key).not_to eq(f2.cache_key)
      end
    end

    context "where facet names differ" do
      let(:facet_data_2) do
        {
          "type" => "multi-select",
          "name" => "Test values 2",
          "key" => "test_values",
          "preposition" => "of value",
          "allowed_values" => allowed_values,
        }
      end

      specify "cache keys should differ" do
        f1 = described_class.new(facet_data, "1")
        f2 = described_class.new(facet_data_2, "1")
        expect(f1.cache_key).not_to eq(f2.cache_key)
      end
    end
  end
end
