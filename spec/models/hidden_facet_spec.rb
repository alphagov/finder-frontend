require "spec_helper"

describe HiddenFacet do
  subject { described_class.new(facet_data, value) }

  let(:facet_data) do
    {
      "key" => "test_facet",
      "name" => "Test facet",
      "preposition" => "of value",
      "allowed_values" => [{ "value" => "hidden_value" }],
    }
  end
  let(:value) { nil }

  it { is_expected.not_to be_user_visible }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { expect(subject.to_partial_path).to eql("hidden_facet") }
    end
  end

  describe "#query_params" do
    context "value selected" do
      let(:value) { "hidden_value" }

      it "returns the value" do
        expect(subject.query_params).to eql("test_facet" => %w[hidden_value])
      end
    end

    context "invalid value selected" do
      let(:value) { "not_allowed_value" }

      it "removes the invalid values" do
        expect(subject.query_params).to eql("test_facet" => [])
      end
    end

    context "no allowed values specified" do
      let(:facet_data) do
        {
          "key" => "test_facet",
          "name" => "Test facet",
          "preposition" => "of value",
          "allowed_values" => [],
        }
      end
      let(:value) { "hidden_value" }

      it "returns the values without validation" do
        expect(subject.query_params).to eql("test_facet" => %w[hidden_value])
      end
    end
  end
end
