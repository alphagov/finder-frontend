require "spec_helper"

describe OptionSelectFacet do
  subject { described_class.new(facet_data, value) }

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
  let(:value) { nil }

  it { is_expected.to be_user_visible }

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { %w[allowed-value-1] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")
      end
    end

    context "multiple values" do
      let(:value) { %w[allowed-value-1 allowed-value-2] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_values")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Allowed value 2")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("test_values")
      end
    end

    context "disallowed values" do
      let(:value) { ["disallowed-value-1, disallowed-value-2"] }

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#applied_filters" do
    context "single value" do
      let(:value) { %w[allowed-value-1] }

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Test values",
            label: "Allowed value 1",
            query_params: { "test_values" => %w[allowed-value-1] },
          },
        ])
      end
    end

    context "multiple values" do
      let(:value) { %w[allowed-value-1 allowed-value-2] }

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Test values",
            label: "Allowed value 1",
            query_params: { "test_values" => %w[allowed-value-1] },
          },
          {
            name: "Test values",
            label: "Allowed value 2",
            query_params: { "test_values" => %w[allowed-value-2] },
          },
        ])
      end
    end

    context "disallowed values" do
      let(:value) { ["disallowed-value-1, disallowed-value-2"] }

      it "returns no applied filters" do
        expect(subject.applied_filters).to be_empty
      end
    end

    context "no value" do
      let(:value) { nil }

      it "returns no applied filters" do
        expect(subject.applied_filters).to be_empty
      end
    end
  end

  describe "#query_params" do
    context "value selected" do
      let(:value) { "allowed-value-1" }

      specify do
        expect(subject.query_params).to eql("test_values" => %w[allowed-value-1])
      end
    end
  end

  describe "#unselected?" do
    let(:value) { ["disallowed-value-1, disallowed-value-2"] }

    context "no selected values" do
      it { is_expected.to be_unselected }
    end

    context "some selected values" do
      let(:value) { "1" }

      let(:facet_data) do
        {
          "type" => "multi-select",
          "name" => "Test values",
          "key" => "test_values",
          "preposition" => "of value",
          "allowed_values" => [{ "label" => "One", "value" => "1" }],
        }
      end

      it { is_expected.not_to be_unselected }
    end
  end

  describe "#cache_key" do
    context "where facet allowed values differ in order" do
      subject { described_class.new(facet_data, "1") }

      let(:other_facet) { described_class.new(facet_data.merge({ "allowed_values" => allowed_values_2 }), "1") }

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
        expect(subject.cache_key).not_to eq(other_facet.cache_key)
      end
    end

    context "where facet names differ" do
      subject { described_class.new(facet_data, "1") }

      let(:other_facet) { described_class.new(facet_data.merge({ "name" => "Test values 2" }), "1") }

      specify "cache keys should differ" do
        expect(subject.cache_key).not_to eq(other_facet.cache_key)
      end
    end
  end
end
