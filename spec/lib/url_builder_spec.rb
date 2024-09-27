require "spec_helper"

describe UrlBuilder do
  let(:builder) { described_class.new(path, query_params) }
  let(:extra_params) { {} }
  let(:path) { "/search/all" }

  describe "#url" do
    context "when given a path and query params" do
      subject(:url) { builder.url }

      let(:query_params) do
        {
          keywords: "harry potter",
          order: "relevance",
          public_timestamp: {
            from: 2005,
            to: 2015,
          },
          organisations: %w[
            ministry-of-magic
            hogwarts
          ],
        }
      end

      it "builds a url with a query" do
        expect(url).to eq("/search/all?#{query_params.to_query}")
      end
    end

    context "when given a path, query params, and additional params" do
      subject(:url) { builder.url(page: 20) }

      let(:query_params) { { keywords: "dumbledore" } }

      it "builds a url that includes the additional params" do
        expect(url).to eq("/search/all?keywords=dumbledore&page=20")
      end
    end
  end

  describe "#url_except" do
    subject(:url) { builder.url_except(excepted) }

    let(:query_params) do
      {
        keywords: "dumbledore",
        page: 20,
        hash: { a: 1, b: 2, c: 2 },
        array: %w[one two],
        single_value: "value",
      }
    end

    let(:excepted) { { page: 20, hash: { b: 2, c: 3 }, array: %w[one], single_value: %w[value] } }

    it "builds a url without the excluded params, ignoring non-matching values" do
      expect(url).to eq("/search/all?array%5B%5D=two&hash%5Ba%5D=1&hash%5Bc%5D=2&keywords=dumbledore")
    end
  end
end
