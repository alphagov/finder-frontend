require "spec_helper"

describe FiltersPresenter do
  subject(:filters_presenter) { described_class.new(facets, finder_url_builder) }

  let(:facets) { [] }
  let(:finder_url_builder) { instance_double(UrlBuilder) }

  let(:facet_without_applied_filters) do
    double(
      "Facet",
      key: "facet_without_applied_filters",
      has_filters?: false,
      applied_filters: [],
    )
  end
  let(:facet_with_applied_filters) do
    double(
      "Facet",
      key: "facet_with_applied_filters",
      has_filters?: true,
      applied_filters: [
        { name: "name", label: "label", query_params: { key: %w[value] } },
        {
          name: "name2",
          label: "label2",
          visually_hidden_prefix: "Get rid of",
          query_params: { key2: %w[value2] },
        },
      ],
    )
  end
  let(:another_facet_with_applied_filters) do
    double(
      "Facet",
      key: "another_facet_with_applied_filters",
      has_filters?: true,
      applied_filters: [
        { name: "name1", label: "label1", query_params: { key1: %w[value1] } },
        { name: "name2",
          label: "label2",
          query_params: {
            key1: %w[anothervalue1], key2: { value2: "subvalue" }
          } },
      ],
    )
  end
  let(:active_sort_facet) { double("SortFacet", key: "order", has_filters?: true) }
  let(:inactive_sort_facet) { double("SortFacet", key: "order", has_filters?: false) }

  describe "#any_filters" do
    context "when there are no facets" do
      let(:facets) { [] }

      it { is_expected.not_to be_any_filters }
    end

    context "when there are only facets without applied filters" do
      let(:facets) { [facet_without_applied_filters, facet_without_applied_filters] }

      it { is_expected.not_to be_any_filters }
    end

    context "when there is at least one facet with applied filters" do
      let(:facets) { [facet_without_applied_filters, facet_with_applied_filters] }

      it { is_expected.to be_any_filters }
    end
  end

  describe "#reset_url" do
    subject(:reset_url) { filters_presenter.reset_url }

    context "when there are no facets" do
      let(:facets) { [] }

      it { is_expected.to be_nil }
    end

    context "when there are only facets without applied filters" do
      let(:facets) { [facet_without_applied_filters, facet_without_applied_filters] }

      it { is_expected.to be_nil }
    end

    context "when there are facets with applied filters" do
      let(:facets) { [facet_with_applied_filters, another_facet_with_applied_filters] }

      before do
        allow(finder_url_builder).to receive(:url_except_keys)
          .with(containing_exactly(:key, :key1, :key2))
          .and_return("/search/foo")
      end

      it "returns the expected reset URL" do
        expect(reset_url).to eq("/search/foo")
      end
    end
  end

  describe "#summary_items" do
    subject(:summary_items) { described_class.new(facets, finder_url_builder).summary_items }

    context "when there are no facets" do
      let(:facets) { [] }

      it { is_expected.to be_empty }
    end

    context "when there are only facets without applied filters" do
      let(:facets) { [facet_without_applied_filters, facet_without_applied_filters] }

      it { is_expected.to be_empty }
    end

    context "when there is at least one facet with applied filters" do
      let(:facets) { [facet_without_applied_filters, facet_with_applied_filters] }

      before do
        allow(finder_url_builder).to receive(:url_except).with({ key: %w[value] })
          .and_return("/search/foo")
        allow(finder_url_builder).to receive(:url_except).with({ key2: %w[value2] })
          .and_return("/search/foo2")
      end

      it "returns the expected summary items" do
        expect(summary_items).to contain_exactly(
          {
            label: "name",
            value: "label",
            displayed_text: "name: label",
            remove_href: "/search/foo",
            visually_hidden_prefix: "Remove filter",
          },
          {
            label: "name2",
            value: "label2",
            displayed_text: "name2: label2",
            remove_href: "/search/foo2",
            visually_hidden_prefix: "Get rid of",
          },
        )
      end
    end
  end

  describe "#summary_heading_text and #reset_link_text" do
    context "when neither filters nor sorting are active" do
      let(:facets) { [facet_without_applied_filters, inactive_sort_facet] }

      it "returns default text" do
        expect(filters_presenter.summary_heading_text).to eq("Active filters")
        expect(filters_presenter.reset_link_text).to eq("Clear all filters")
      end
    end

    context "when filters are active but sorting is not" do
      let(:facets) { [facet_with_applied_filters, inactive_sort_facet] }

      it "returns the expected summary heading text and reset link text" do
        expect(filters_presenter.summary_heading_text).to eq("Active filters")
        expect(filters_presenter.reset_link_text).to eq("Clear all filters")
      end
    end

    context "when sorting is active but filters are not" do
      let(:facets) { [facet_without_applied_filters, active_sort_facet] }

      it "returns the expected summary heading text and reset link text" do
        expect(filters_presenter.summary_heading_text).to eq("Active sorting")
        expect(filters_presenter.reset_link_text).to eq("Clear all sorting")
      end
    end

    context "when both filters and sorting are active" do
      let(:facets) do
        [facet_with_applied_filters, active_sort_facet]
      end

      it "returns the expected summary heading text and reset link text" do
        expect(filters_presenter.summary_heading_text).to eq("Active filters and sorting")
        expect(filters_presenter.reset_link_text).to eq("Clear all filters and sorting")
      end
    end
  end
end
