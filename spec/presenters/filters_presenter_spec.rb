require "spec_helper"

describe FiltersPresenter do
  subject(:filters_presenter) { described_class.new(facets, finder_url_builder) }

  let(:facets) { [] }
  let(:finder_url_builder) { instance_double(UrlBuilder) }

  let(:facet_without_applied_filters) { double("Facet", has_filters?: false, applied_filters: []) }
  let(:facet_with_applied_filters) do
    double(
      "Facet",
      has_filters?: true,
      applied_filters: [{ name: "name", label: "label", query_params: { key: %w[value] } }],
    )
  end
  let(:another_facet_with_applied_filters) do
    double(
      "Facet",
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
      end

      it "returns the expected summary items" do
        expect(summary_items).to contain_exactly({
          label: "name",
          value: "label",
          displayed_text: "name: label",
          remove_href: "/search/foo",
          visually_hidden_prefix: "Remove filter",
        })
      end
    end
  end
end
