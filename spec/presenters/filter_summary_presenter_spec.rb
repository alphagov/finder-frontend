require "spec_helper"

describe FilterSummaryPresenter do
  subject(:presenter) { described_class.new(sort_presenter) }

  describe "#items" do
    context "when the sort order is the default" do
      let(:sort_presenter) { instance_double(SortPresenter, default?: true) }

      it "returns an empty array" do
        expect(presenter.items).to eq([])
      end
    end

    context "when the sort order is non-default" do
      let(:sort_presenter) do
        instance_double(SortPresenter, default?: false, selected_option_name: "Flux capacity")
      end

      it "returns an array containing the expected sort item" do
        expect(presenter.items).to include(
          label: "Sort by",
          value: "Flux capacity",
          remove_href: "",
          visually_hidden_prefix: "Remove",
        )
      end
    end
  end
end
