require "spec_helper"

describe HiddenClearableFacet do
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

  let(:facet_class) { described_class }

  describe "#sentence_fragment" do
    context "single value" do
      subject { facet_class.new(facet_data, %w[allowed-value-1]) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_facet")
      end
    end

    context "multiple values" do
      subject { facet_class.new(facet_data, %w[allowed-value-1 allowed-value-2]) }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Allowed value 1")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("test_facet")

        expect(subject.sentence_fragment["values"].last["label"]).to eql("Allowed value 2")
        expect(subject.sentence_fragment["values"].last["parameter_key"]).to eql("test_facet")
      end
    end

    context "disallowed values" do
      subject { facet_class.new(facet_data, ["disallowed-value-1, disallowed-value-2"]) }

      specify { expect(subject.sentence_fragment).to be_nil }
    end
  end

  describe "#has_filters?" do
    context "no value" do
      subject { facet_class.new(facet_data, nil) }

      specify do
        expect(subject.has_filters?).to be(false)
      end
    end

    context "has a value" do
      subject { facet_class.new(facet_data, %w[allowed-value-1]) }

      specify do
        expect(subject.has_filters?).to be(true)
      end
    end
  end

  describe "#query_params" do
    context "value selected" do
      subject { described_class.new(facet_data, "allowed-value-1") }

      specify do
        expect(subject.query_params).to eql("test_facet" => %w[allowed-value-1])
      end
    end
  end
end
