require "spec_helper"

describe FilterSummaryPresenter do
  subject(:presenter) { described_class.new(sort_presenter, url_builder) }

  let(:sort_presenter) { instance_double(SortPresenter, default?: true) }
  let(:url_builder) { instance_double(UrlBuilder) }

  describe "#items" do
    context "when the sort order is the default" do
      let(:sort_presenter) { instance_double(SortPresenter, default?: true) }

      it "returns an empty array" do
        expect(presenter.items).to eq([])
      end
    end

    context "when the sort order is non-default" do
      before do
        allow(url_builder).to receive(:url_except_params).with(:order).and_return("/search?foo=bar")
      end

      let(:sort_presenter) do
        instance_double(SortPresenter, default?: false, selected_option_name: "Flux capacity")
      end

      it "returns an array containing the expected sort item" do
        expect(presenter.items).to include(
          label: "Sort by",
          value: "Flux capacity",
          remove_href: "/search?foo=bar",
          visually_hidden_prefix: "Remove",
        )
      end
    end
  end

  describe "#clear_all_href" do
    before do
      allow(url_builder).to receive(:url_except_params).with(:order).and_return("/search")
    end

    it "returns the URL for the current search with the sort order removed" do
      expect(presenter.clear_all_href).to eq("/search")
    end
  end
end
