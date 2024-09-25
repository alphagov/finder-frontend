require "spec_helper"

describe SortFacet do
  subject(:sort_facet) { described_class.new }

  describe "#name" do
    it "returns a value" do
      expect(sort_facet.name).not_to be_blank
    end
  end

  describe "#ga4_section" do
    it "is identical to #name" do
      expect(sort_facet.ga4_section).to eq(sort_facet.name)
    end
  end

  describe "#to_partial_path" do
    it "is the underscored class name" do
      expect(sort_facet.to_partial_path).to eq("sort_facet")
    end
  end

  it { is_expected.to be_user_visible }
  it { is_expected.to be_filterable }
  it { is_expected.not_to be_hide_facet_tag }
  it { is_expected.not_to be_metadata }
end
