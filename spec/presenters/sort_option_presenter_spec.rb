require "spec_helper"

RSpec.describe SortOptionPresenter do
  subject(:sort_option) { described_class.new(label: "Updated (newest)", key: "-public_timestamp") }
  subject(:sort_option_with_value) { described_class.new(label: "Updated (newest)", value: "frogs-frogs-frogs", key: "-public_timestamp") }
  subject(:default_sort_option) { described_class.new(label: "Most viewed", key: "most-viewed", default: true) }
  subject(:relevance_sort_option) { described_class.new(label: "Show least relevant", key: "-relevance") }

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
      expect(default_sort_option.default?).to eq(true)
    end

    it "returns false if option is NOT default" do
      expect(sort_option.default?).to eq(false)
    end
  end

  describe "to_hash" do
    it "returns a hash including label, value, tracking_attributes" do
      expect(sort_option.to_hash).to eq(
        data_track_action: "clicked",
        data_track_category: "dropDownClicked",
        data_track_label: "Updated (newest)",
        disabled: false,
        label: "Updated (newest)",
        selected: false,
        value: "updated-newest",
      )
    end
  end
end
