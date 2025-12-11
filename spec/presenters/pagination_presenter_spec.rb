require "spec_helper"

describe PaginationPresenter do
  subject(:links) { presenter.next_and_prev_links }

  let(:presenter) do
    described_class.new(
      per_page:,
      start_offset:,
      total_results:,
      url_builder:,
    )
  end
  let(:per_page) {}
  let(:start_offset) {}
  let(:total_results) {}
  let(:url_builder) { UrlBuilder.new("/search") }

  describe "#next_and_prev_links" do
    context "when per_page is unset" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when there are no other pages with results" do
      let(:per_page) { 20 }
      let(:total_results) { 20 }
      let(:start_offset) { 1 }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when there are only next pages" do
      let(:per_page) { 20 }
      let(:total_results) { 100 }
      let(:start_offset) { 1 }

      it "returns a next page link" do
        expect(subject).to eq(
          next_page: {
            label: "2 of 5",
            title: "Next page",
            href: "/search?page=2",
          },
        )
      end
    end

    context "when there are only previous pages" do
      let(:per_page) { 20 }
      let(:total_results) { 100 }
      let(:start_offset) { 80 }

      it "returns a previous page link" do
        expect(subject).to eq(
          previous_page: {
            label: "4 of 5",
            title: "Previous page",
            href: "/search?page=4",
          },
        )
      end
    end

    context "when there are next and previous pages" do
      let(:per_page) { 20 }
      let(:total_results) { 100 }
      let(:start_offset) { 20 }

      it "returns next and previous page links" do
        expect(subject).to eq(
          next_page: {
            label: "3 of 5",
            title: "Next page",
            href: "/search?page=3",
          },
          previous_page: {
            label: "1 of 5",
            title: "Previous page",
            href: "/search?page=1",
          },
        )
      end
    end

    context "when the page numbers are large" do
      let(:per_page) { 1 }
      let(:total_results) { 1989 }
      let(:start_offset) { 1312 }

      it "returns links with separators" do
        expect(subject[:previous_page][:label]).to eq("1,312 of 1,989")
        expect(subject[:next_page][:label]).to eq("1,314 of 1,989")
      end
    end
  end
end
