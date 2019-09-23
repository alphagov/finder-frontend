require "spec_helper"

describe UrlBuilder do
  let(:builder) { described_class.new(path, query_params) }
  let(:extra_params) { {} }
  let(:path) { "/search/all" }

  describe "#url_builder" do
    context "when given a path and query params" do
      subject(:url) { builder.url }

      let(:query_params) {
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
      }

      it "builds a url with a query" do
        expect(url).to eq("/search/all?" + query_params.to_query)
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
end
