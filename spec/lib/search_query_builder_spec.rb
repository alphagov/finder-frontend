require "spec_helper"
require "search_query_builder"

describe SearchQueryBuilder do
  subject(:query) {
    SearchQueryBuilder.new(
      filter_query_builder: filter_query_builder,
      facet_query_builder: facet_query_builder,
      finder_content_item: finder_content_item,
      params: params,
    ).call
  }

  # TODO assert the correct arguments are passed to this and that the response
  # is merged into the returned query
  let(:filter_query_builder) { double(call: {}) }

  let(:facet_query_builder) { double(call: {}) }

  let(:finder_content_item) {
    double(
      details: double(
        facets: facets,
        filter: double(to_h: filter),
        default_order: default_order,
        default_documents_per_page: nil,
      ),
    )
  }

  let(:facets) { [] }
  let(:filter) { {} }
  let(:default_order) { nil }

  let(:params) { {} }

  it "should include a count" do
    expect(query).to include("count" => 1000)
  end

  context "with pagination" do
    let(:finder_content_item) {
      double(
        details: double(
          facets: facets,
          filter: double(to_h: filter),
          default_order: default_order,
          default_documents_per_page: 10
        ),
      )
    }

    it "should use documents_per_page from content item" do
      expect(query).to include({
          "count" => 10,
          "start" => 0
        })
    end
  end

  context "without any facets" do
    it "should include base return fields" do
      expect(query).to include(
        "fields" => "title,link,description,public_timestamp",
      )
    end
  end

  context "with facets" do
    let(:facets) {
      [
        double(
          key: "alpha",
          filterable: false,
        ),
        double(
          key: "beta",
          filterable: false,
        ),
      ]
    }

    it "should include base and extra return fields" do
      expect(query).to include(
        "fields" => "title,link,description,public_timestamp,alpha,beta",
      )
    end

    it "should include fields from filter_query_builder prefixed with filter_" do
      expect(filter_query_builder).to receive(:call).with(
        facets: facets,
        user_params: params,
      ).and_return(
        "alpha" => "value",
        "beta" => "another_value",
      )

      expect(query).to include(
        "filter_alpha" => "value",
        "filter_beta" => "another_value",
      )
    end
  end

  context "without keywords" do
    it "should not include a keyword query" do
      expect(query).not_to include("q")
    end

    it "should include an order query" do
      expect(query).to include("order" => "-public_timestamp")
    end

    context "with a custom order" do
      let(:default_order) { "custom_field" }

      it "should include a custom order query" do
        expect(query).to include("order" => "custom_field")
      end
    end
  end

  context "with keywords" do
    let(:params) {
      {
        "keywords" => "mangoes",
      }
    }

    it "should include a keyword query" do
      expect(query).to include("q" => "mangoes")
    end

    it "should not include an order query" do
      expect(query).not_to include("order")
    end
  end

  context "with a base filter" do
    let(:filter) { { "document_type" => "news_story" } }

    it "should include fields prefixed with filter_" do
      expect(query).to include("filter_document_type" => "news_story")
    end
  end
end
