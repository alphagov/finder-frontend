require "spec_helper"

RSpec.describe FacetPresenter do
  subject(:facet_presenter) { described_class.new(facet, section_index, section_count) }

  let(:facet) do
    instance_double(
      Facet,
      key: "a_facet",
      name: "A facet",
      status_text: "42 selected",
    )
  end
  let(:section_index) { 0 }
  let(:section_count) { 2 }

  it "delegates methods to the facet" do
    expect(facet_presenter.key).to eq("a_facet")
  end

  describe "#section_index" do
    it "exposes the section index as a 1-based index" do
      expect(facet_presenter.section_index).to eq(1)
    end

    context "when no section index is provided" do
      let(:section_index) { nil }

      it "exposes nil as the section index" do
        expect(facet_presenter.section_index).to be_nil
      end
    end
  end

  describe "#section_count" do
    it "exposes the section count" do
      expect(facet_presenter.section_count).to eq(2)
    end
  end

  describe "#section_attributes" do
    it "returns a hash of common attributes for the filter section component" do
      expect(facet_presenter.section_attributes).to eq({
        heading_text: "A facet",
        status_text: "42 selected",
        index_section: 1,
        index_section_count: 2,
        data_attributes: {
          ga4_index: {
            index_section: 1,
            index_section_count: 2,
          },
        },
      })
    end
  end
end
