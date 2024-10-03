require "spec_helper"

describe SortFacet do
  subject(:sort_facet) { described_class.new(content_item, filter_params) }

  let(:content_item) { instance_double(ContentItem, sort_options:) }
  let(:sort_options) do
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" },
      { "name" => "Relevance" },
    ]
  end
  let(:filter_params) { {} }

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

  describe "#has_filters?" do
    context "when no sort order is selected" do
      it { is_expected.not_to have_filters }
    end

    context "when a sort order is selected but it doesn't exist" do
      let(:filter_params) { { "order" => "invalid" } }

      it { is_expected.not_to have_filters }
    end

    context "when a default sort order is selected" do
      let(:filter_params) { { "order" => "most-viewed" } }

      it { is_expected.not_to have_filters }
    end

    context "when a custom sort order is selected" do
      let(:filter_params) { { "order" => "updated-newest" } }

      it { is_expected.to have_filters }
    end
  end

  describe "#applied_filters" do
    context "when no sort order is selected" do
      it "returns an empty array" do
        expect(sort_facet.applied_filters).to eq([])
      end
    end

    context "when a sort order is selected but it doesn't exist" do
      let(:filter_params) { { "order" => "invalid" } }

      it "returns an empty array" do
        expect(sort_facet.applied_filters).to eq([])
      end
    end

    context "when a default sort order is selected" do
      let(:filter_params) { { "order" => "most-viewed" } }

      it "returns an empty array" do
        expect(sort_facet.applied_filters).to eq([])
      end
    end

    context "when a custom sort order is selected" do
      let(:filter_params) { { "order" => "updated-newest" } }

      it "returns the selected sort order" do
        expect(sort_facet.applied_filters).to eq([{
          name: "Sort by",
          label: "Updated (newest)",
          query_params: { "order" => "updated-newest" },
          visually_hidden_prefix: "Remove",
        }])
      end
    end
  end

  describe "#status_text" do
    subject(:status_text) { sort_facet.status_text }

    context "when no sort order is selected" do
      it { is_expected.to be_nil }
    end

    context "when a sort order is selected but it doesn't exist" do
      let(:filter_params) { { "order" => "invalid" } }

      it { is_expected.to be_nil }
    end

    context "when a default sort order is selected" do
      let(:filter_params) { { "order" => "most-viewed" } }

      it { is_expected.to be_nil }
    end

    context "when a custom sort order is selected" do
      let(:filter_params) { { "order" => "updated-newest" } }

      it { is_expected.to eq("Updated (newest)") }
    end
  end

  it { is_expected.to be_user_visible }
  it { is_expected.to be_filterable }
  it { is_expected.not_to be_hide_facet_tag }
  it { is_expected.not_to be_metadata }
end
