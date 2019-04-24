require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe SortOptionPresenter do
  subject(:sort_option) { described_class.new(label: "Updated (newest)" , key: "-public_timestamp") }
  subject(:default_sort_option) { described_class.new(label: "Most viewed", key: "most-viewed", default: true) }
  subject(:relevance_sort_option) { described_class.new(label: "Show least relevant", key: "-relevance",) }

  describe "#value" do
    it "returns label parameterized" do
      expect(sort_option.value).to eq("updated-newest")
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

  describe "relevance?" do
    it "returns true if option is relevance" do
      expect(relevance_sort_option.relevance?).to eq(true)
    end

    it "returns false if option is NOT relevance" do
      expect(sort_option.relevance?).to eq(false)
    end
  end

  describe "to_select_format" do
    it "returns an array including label, value, tracking_attributes" do
      expect(sort_option.to_select_format).to eq([
        "Updated (newest)",
        "updated-newest",
        {
          'data-track-category' => 'dropDownClicked',
          'data-track-action' => 'clicked',
          'data-track-label' => "Updated (newest)"
        }
      ])
    end
  end
end
