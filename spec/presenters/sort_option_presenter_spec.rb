require "spec_helper"

RSpec.describe SortOptionPresenter do
  subject(:relevance_sort_option) { described_class.new(label: "Show least relevant", key: "-relevance") }

  let(:sort_option) { described_class.new(label: "Updated (newest)", key: "-public_timestamp") }

  let(:sort_option_with_value) { described_class.new(label: "Updated (newest)", value: "frogs-frogs-frogs", key: "-public_timestamp") }

  let(:default_sort_option) { described_class.new(label: "Most viewed", key: "most-viewed", default: true) }

  let(:disabled_sort_option) { described_class.new(label: "Show in order of redness", key: "redness", disabled: true) }

  describe "#value" do
    context "a value is provided" do
      it "returns the given value" do
        expect(sort_option_with_value.value).to eq("frogs-frogs-frogs")
      end
    end

    context "a value is not provided" do
      it "returns label parameterized" do
        expect(sort_option.value).to eq("updated-newest")
      end
    end
  end

  describe "default?" do
    it "returns true if option is default" do
      expect(default_sort_option.default?).to be(true)
    end

    it "returns false if option is NOT default" do
      expect(sort_option.default?).to be(false)
    end
  end

  describe "to_hash" do
    it "returns a hash including label, value, tracking_attributes" do
      expect(sort_option.to_hash).to eq(
        data_ga4_track_label: "Updated (newest)",
        disabled: false,
        label: "Updated (newest)",
        selected: false,
        value: "updated-newest",
      )
    end
  end

  describe "#to_radio_option" do
    it "returns a hash appropriate for the radio component" do
      expect(sort_option.to_radio_option).to eq(
        value: "updated-newest",
        text: "Updated (newest)",
        checked: false,
      )
    end

    it "returns nil for a disabled option" do
      expect(disabled_sort_option.to_radio_option).to be_nil
    end
  end
end
