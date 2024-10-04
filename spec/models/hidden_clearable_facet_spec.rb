require "spec_helper"

describe HiddenClearableFacet do
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
        "label" => "Allowed value 3",
        "value" => "allowed-value-3",
      },
    ]
  end

  let(:facet_data) do
    {
      "key" => "test_facet",
      "name" => "Test facet",
      "preposition" => "of value",
      "allowed_values" => allowed_values,
    }
  end
  let(:value) { nil }

  it { is_expected.not_to be_user_visible }

  describe "#sentence_fragment" do
    context "single value" do
      let(:value) { %w[allowed-value-1] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_facet")
      end
    end

    context "multiple values" do
      let(:value) { %w[allowed-value-1 allowed-value-2] }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_facet")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Allowed value 2")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("test_facet")
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
            name: "Test facet",
            label: "Allowed value 1",
            query_params: { "test_facet" => %w[allowed-value-1] },
          },
        ])
      end
    end

    context "multiple values" do
      let(:value) { %w[allowed-value-1 allowed-value-2] }

      it "returns the expected applied filters" do
        expect(subject.applied_filters).to eql([
          {
            name: "Test facet",
            label: "Allowed value 1",
            query_params: { "test_facet" => %w[allowed-value-1] },
          },
          {
            name: "Test facet",
            label: "Allowed value 2",
            query_params: { "test_facet" => %w[allowed-value-2] },
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

  describe "#has_filters?" do
    context "no value" do
      let(:value) { nil }

      it { is_expected.not_to have_filters }
    end

    context "has a value" do
      let(:value) { %w[allowed-value-1] }

      it { is_expected.to have_filters }
    end
  end

  describe "#query_params" do
    context "value selected" do
      let(:value) { "allowed-value-1" }

      specify do
        expect(subject.query_params).to eql("test_facet" => %w[allowed-value-1])
      end
    end
  end
end
