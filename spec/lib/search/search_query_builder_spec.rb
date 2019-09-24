require "spec_helper"

describe Search::QueryBuilder do
  subject(:queries) do
    described_class.new(
      finder_content_item: finder_content_item,
      params: params,
    ).call
  end

  let(:query) { queries.first }

  let(:finder_content_item) {
    ContentItem.new(
      "base_path" => "/finder-path",
      "details" => {
        "facets" => facets,
        "filter" => filter,
        "reject" => reject,
        "default_order" => default_order,
        "default_documents_per_page" => nil,
      },
)
  }

  let(:facets) { [] }
  let(:filter) { {} }
  let(:reject) { {} }
  let(:default_order) { nil }

  let(:params) { {} }

  it "should include a count" do
    expect(query).to include("count" => 1500)
  end

  context "with pagination" do
    let(:finder_content_item) {
      ContentItem.new(
        "details" => {
          "facets" => facets,
          "filter" => filter,
          "reject" => reject,
          "default_order" => default_order,
          "default_documents_per_page" => 10,
        },
)
    }

    it "should use documents_per_page from content item" do
      expect(query).to include(
        "count" => 10,
        "start" => 0,
      )
    end
  end

  context "without any facets" do
    it "should include base return fields" do
      expect(query).to include(
        "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id",
      )
    end
  end

  context "with facets" do
    let(:facets) {
      [
        {
          "key" => "alpha",
          "filterable" => false,
        },
        {
          "key" => "beta",
          "filterable" => false,
        },
      ]
    }

    let(:reject) {
      {
        alpha: "value",
      }
    }

    it "should include base and extra return fields" do
      expect(query).to include(
        "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,alpha,beta",
      )
    end

    it "should include reject fields prefixed with reject_" do
      expect(query).to include(
        "reject_alpha" => "value",
      )
    end

    context "facets with filter_keys" do
      before do
        facets.first["filter_key"] = "zeta"
      end

      it "should use the filter value in fields" do
        expect(query).to include(
          "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,zeta,beta",
        )
      end
    end

    context "facets with or combine_mode" do
      before do
        facets.first["filterable"] = true
        facets.first["type"] = "text"

        facets.second["filterable"] = true
        facets.second["type"] = "text"
        facets.second["combine_mode"] = "or"
      end

      let(:params) do
        {
          "alpha" => "test",
          "beta" => "test",
        }
      end

      it "should generate two queries" do
        expect(queries.count).to eq(2)
      end

      it "should filter on just alpha in the first query" do
        expect(queries.first["filter_alpha"]).to eq(%w(test))
        expect(queries.first["filter_beta"]).to be_nil
      end

      it "should filter on both alpha and beta in the second query" do
        expect(queries.second["filter_alpha"]).to be_nil
        expect(queries.second["filter_beta"]).to eq(%w(test))
      end
    end

    context "of 'content_id' type" do
      let(:allowed_values) do
        [
          { "label" => "EU citizens", "value" => "yes", "content_id" => "yes-cont-id" },
          { "label" => "No EU citizens", "value" => "no", "content_id" => "no-cont-id" },
        ]
      end

      let(:intellectual_property_allowed_values) do
        [
          { "label" => "Copyright", "value" => "copyright", "content_id" => "copyright-cont-id" },
          { "label" => "Patents", "value" => "patents", "content_id" => "patents-cont-id" },
        ]
      end

      before do
        facets.first["filterable"] = true
        facets.first["type"] = "content_id"
        facets.first["key"] = "employ_eu_citizens"
        facets.first["filter_key"] = "any_facet_values"
        facets.first["allowed_values"] = allowed_values
        facets.second["filterable"] = true
        facets.second["type"] = "content_id"
        facets.second["key"] = "intellectual_property"
        facets.second["filter_key"] = "any_facet_values"
        facets.second["allowed_values"] = intellectual_property_allowed_values
      end

      let(:params) do
        {
          "employ_eu_citizens" => "yes",
          "intellectual_property" => %w[copyright patents],
        }
      end

      context "with `and` combine_mode" do
        it "adds a `filter_facet_values` filter with the content_id" do
          expect(query["filter_any_facet_values"]).to eq(%w[yes-cont-id copyright-cont-id patents-cont-id])
        end
      end

      context "with `or` combine_mode" do
        before do
          facets.second["combine_mode"] = "or"
        end

        it "sends the correct `filter_any_facet_values` to each query" do
          expect(queries.first["filter_any_facet_values"]).to eq(%w[yes-cont-id])
          expect(queries.second["filter_any_facet_values"]).to eq(%w[copyright-cont-id patents-cont-id])
        end
      end
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

    context "longer than the maximum query length" do
      let(:params) {
        {
          "keywords" => "a" * 1024,
        }
      }

      it "should include a truncated" do
        expect(query).to include("q" => "a" * described_class::MAX_QUERY_LENGTH)
      end
    end

    context "without stopwords" do
      let(:params) {
        {
          "keywords" => "a mango",
        }
      }

      it "should include stopwords in search" do
        expect(query).to include("q" => "a mango")
      end
    end

    context "with stopwords" do
      let(:finder_content_item) {
        ContentItem.new(
          "base_path" => "/find-eu-exit-guidance-business",
          "details" => {
            "facets" => facets,
            "filter" => filter,
            "reject" => reject,
            "default_order" => default_order,
            "default_documents_per_page" => 10,
          },
)
      }

      it "should not include stopwords in search" do
        params = {
          "keywords" => "a mango",
        }

        query = described_class.new(
          finder_content_item: finder_content_item,
          params: params,
        ).call.first

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "a mango")
      end

      it "strips punctuation from stopword check" do
        params = {
          "keywords" => "a, isn't a mango is it?",
        }

        query = described_class.new(
          finder_content_item: finder_content_item,
          params: params,
        ).call.first

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "a, isn't a mango is it?")
      end

      it "ignores case of keywords" do
        params = {
          "keywords" => "A mango",
        }

        query = described_class.new(
          finder_content_item: finder_content_item,
          params: params,
        ).call.first

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "A mango")
      end

      it "does not strip numbers from search" do
        params = {
          "keywords" => "50",
        }

        query = described_class.new(
          finder_content_item: finder_content_item,
          params: params,
        ).call.first

        expect(query).to include("q" => "50")
      end
    end
  end

  context "with debug parameters" do
    let(:params) {
      {
        "debug" => "yes",
      }
    }

    it "should include a debug query" do
      expect(query).to include("debug" => "yes")
    end
  end

  context "without debug parameters" do
    it "should not include a debug query" do
      expect(query).not_to include("debug")
    end
  end

  context "with A/B parameters" do
    let(:ab_params) {
      {
        test_one: "a",
        test_two: "b",
      }
    }

    it "should include an A/B query" do
      query = described_class.new(
        finder_content_item: finder_content_item,
        ab_params: ab_params,
      ).call.first

      expect(query).to include("ab_tests" => "test_one:a,test_two:b")
    end
  end

  context "with a base filter" do
    let(:filter) { { "document_type" => "news_story" } }

    it "should include fields prefixed with filter_" do
      expect(query).to include("filter_document_type" => "news_story")
    end
  end

  describe "#start" do
    it "starts at zero by default" do
      query = query_with_params({})

      expect(query["start"]).to eql(0)
    end

    it "starts at zero when page param is zero" do
      query = query_with_params("page" => 0)

      expect(query["start"]).to eql(0)
    end

    it "starts at zero when page param is nil" do
      query = query_with_params("page" => nil)

      expect(query["start"]).to eql(0)
    end

    it "starts at zero when page param is empty" do
      query = query_with_params("page" => "")

      expect(query["start"]).to eql(0)
    end

    it "is paginated" do
      query = query_with_params("page" => "10")

      expect(query["start"]).to eql(13500)
    end

    def query_with_params(params)
      described_class.new(
        finder_content_item: finder_content_item,
        params: params,
      ).call.first
    end
  end
end
