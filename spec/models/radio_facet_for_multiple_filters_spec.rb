require "spec_helper"

describe RadioFacetForMultipleFilters do
  subject { described_class.new(facet_data, value, filter_hashes) }

  let(:facet_data) do
    {
      "type" => "radio_facet",
      "key" => "type",
      "value" => "selected_value",
      "allowed_values" => [{ "value" => "selected_value" }],
      "filterable" => true,
    }
  end

  let(:value) { nil }

  let(:filter_hashes) do
    [
      {
        "value" => "value_1",
        "label" => "label_1",
        "filter" => {
          "field" => "value_1",
        },
      },
      {
        "value" => "value_2",
        "label" => "label_2",
        "filter" => {
          "field" => "value_2",
        },
      },
      {
        "value" => "default_value",
        "label" => "default_label",
        "filter" => {
          "field" => "default_feld",
        },
        "default" => true,
      },
    ]
  end

  it { is_expected.to be_user_visible }

  describe "#options" do
    context "valid value" do
      let(:value) { "value_1" }

      it "sets the options, selecting the correct value" do
        expect(subject.options).to eq([
          {
            value: "value_1",
            text: "label_1",
            checked: true,
          },
          {
            value: "value_2",
            text: "label_2",
            checked: false,
          },
          {
            value: "default_value",
            text: "default_label",
            checked: false,
          },
        ])
      end
    end

    context "invalid value" do
      let(:value) { "something" }

      it "sets the options, selecting the default value" do
        expect(subject.options).to include(
          value: "default_value",
          text: "default_label",
          checked: true,
        )
      end
    end
  end

  describe "#query_params" do
    context "value selected" do
      let(:value) { "value_1" }

      specify do
        expect(subject.query_params).to eq("type" => "value_1")
      end
    end
  end
end
