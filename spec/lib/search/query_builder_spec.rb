require "spec_helper"

describe Search::QueryBuilder do
  subject(:query) do
    described_class.new(
      finder_content_item:,
      use_v2_api:,
      v2_serving_config:,
      params:,
    ).call
  end

  let(:finder_content_item) do
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
  end
  let(:use_v2_api) { false }
  let(:v2_serving_config) { nil }

  let(:facets) { [] }
  let(:filter) { {} }
  let(:reject) { {} }
  let(:default_order) { nil }

  let(:params) { {} }

  it "includes a count" do
    expect(query).to include("count" => 1500)
  end

  context "with pagination" do
    let(:finder_content_item) do
      ContentItem.new(
        "details" => {
          "facets" => facets,
          "filter" => filter,
          "reject" => reject,
          "default_order" => default_order,
          "default_documents_per_page" => 10,
        },
      )
    end

    it "uses documents_per_page from content item" do
      expect(query).to include(
        "count" => 10,
        "start" => 0,
      )
    end
  end

  context "without any facets" do
    it "includes base return fields" do
      expect(query).to include(
        "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts",
      )
    end
  end

  context "with facets" do
    let(:facets) do
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
    end

    let(:reject) do
      {
        alpha: "value",
      }
    end

    it "includes base and extra return fields" do
      expect(query).to include(
        "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,alpha,beta",
      )
    end

    it "includes reject fields prefixed with reject_" do
      expect(query).to include(
        "reject_alpha" => "value",
      )
    end

    context "facets with filter_keys" do
      before do
        facets.first["filter_key"] = "zeta"
      end

      it "uses the filter value in fields" do
        expect(query).to include(
          "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,zeta,beta",
        )
      end
    end

    context "of 'content_id' type" do
      let(:allowed_values) do
        [
          { "label" => "EU citizens", "value" => "yes", "content_id" => "yes-cont-id" },
          { "label" => "No EU citizens", "value" => "no", "content_id" => "no-cont-id" },
        ]
      end
      let(:params) do
        {
          "employ_eu_citizens" => "yes",
          "intellectual_property" => %w[copyright patents],
        }
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

      it "adds a `filter_facet_values` filter with the content_id" do
        expect(query["filter_any_facet_values"]).to eq(%w[yes-cont-id copyright-cont-id patents-cont-id])
      end
    end
  end

  context "with nested facets" do
    let(:facets) do
      [
        {
          "filterable" => true,
          "type" => "nested",
          "name" => "Main Facet Name",
          "key" => "main_facet_key_value",
          "preposition" => "with",
          "sub_facet_key" => "sub_facet_key_value",
          "sub_facet_name" => "Sub Facet Name",
          "nested_facet" => true,
          "allowed_values" => [
            {
              "label" => "Allowed value 1",
              "value" => "allowed-value-1",
              "sub_facets" => [
                {
                  "label" => "Sub facet Value 1",
                  "value" => "allowed-value-1-sub-facet-value-1",
                  "main_facet_label" => "Allowed value 1",
                  "main_facet_value" => "allowed-value-1",
                },
                {
                  "label" => "Sub facet Value 2",
                  "value" => "allowed-value-1-sub-facet-value-2",
                  "main_facet_label" => "Allowed value 1",
                  "main_facet_value" => "allowed-value-1",
                },
              ],
            },
          ],
        },
      ]
    end

    context "main and sub facet key params present" do
      let(:params) do
        {
          "main_facet_key_value" => "allowed-value-1",
          "sub_facet_key_value" => "allowed-value-1-sub-facet-value-1",
        }
      end

      it "composes a query including nested facets values" do
        expect(query).to include(
          "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,main_facet_key_value,sub_facet_key_value",
        )
        expect(query["filter_main_facet_key_value"]).to eq %w[allowed-value-1]
        expect(query["filter_sub_facet_key_value"]).to eq %w[allowed-value-1-sub-facet-value-1]
      end
    end

    context "only main facet key param present" do
      let(:params) do
        {
          "main_facet_key_value" => "allowed-value-1",
        }
      end

      it "composes a query including only main value" do
        expect(query).to include(
          "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,main_facet_key_value,sub_facet_key_value",
        )
        expect(query["filter_main_facet_key_value"]).to eq %w[allowed-value-1]
        expect(query["filter_sub_facet_key_value"]).to be_nil
      end
    end

    context "only sub facet key param present" do
      let(:params) do
        {
          "sub_facet_key_value" => "allowed-value-1-sub-facet-value-1",
        }
      end

      it "composes a query including only sub-facet value" do
        expect(query).to include(
          "fields" => "title,link,description_with_highlighting,public_timestamp,popularity,content_purpose_supergroup,content_store_document_type,format,is_historic,government_name,content_id,parts,main_facet_key_value,sub_facet_key_value",
        )
        expect(query["filter_main_facet_key_value"]).to be_nil
        expect(query["filter_sub_facet_key_value"]).to eq %w[allowed-value-1-sub-facet-value-1]
      end
    end
  end

  context "without keywords" do
    it "does not include a keyword query" do
      expect(query).not_to include("q")
    end

    it "includes an order query" do
      expect(query).to include("order" => "-public_timestamp")
    end

    context "with a custom order" do
      let(:default_order) { "custom_field" }

      it "includes a custom order query" do
        expect(query).to include("order" => "custom_field")
      end
    end
  end

  context "with keywords" do
    let(:params) do
      {
        "keywords" => "mangoes",
      }
    end

    it "includes a keyword query" do
      expect(query).to include("q" => "mangoes")
    end

    it "does not include an order query" do
      expect(query).not_to include("order")
    end

    context "longer than the maximum query length" do
      let(:params) do
        {
          "keywords" => "a" * 1024,
        }
      end

      it "includes a truncated" do
        expect(query).to include("q" => "a" * described_class::MAX_QUERY_LENGTH)
      end
    end

    context "with field boosts" do
      let(:finder_content_item) do
        ContentItem.new(
          "base_path" => "/find-licences",
        )
      end

      it "includes field boosts for eligible content items" do
        expect(query).to include("boost_fields" => "licence_transaction_industry")
      end
    end

    context "without stopwords" do
      let(:params) do
        {
          "keywords" => "a mango",
        }
      end

      it "includes stopwords in search" do
        expect(query).to include("q" => "a mango")
      end
    end

    context "with stopwords" do
      let(:finder_content_item) do
        ContentItem.new(
          "base_path" => "/find-licences",
          "details" => {
            "facets" => facets,
            "filter" => filter,
            "reject" => reject,
            "default_order" => default_order,
            "default_documents_per_page" => 10,
          },
        )
      end

      it "does not include stopwords in search" do
        params = {
          "keywords" => "mango licence",
        }

        query = described_class.new(
          finder_content_item:,
          params:,
        ).call

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "mango licence")
      end

      it "strips punctuation from stopword check" do
        params = {
          "keywords" => "certification, mango license?",
        }

        query = described_class.new(
          finder_content_item:,
          params:,
        ).call

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "certification, mango license?")
      end

      it "ignores case of keywords" do
        params = {
          "keywords" => "PERMIT mango",
        }

        query = described_class.new(
          finder_content_item:,
          params:,
        ).call

        expect(query).to include("q" => "mango")
        expect(query).not_to include("q" => "PERMIT mango")
      end

      it "does not strip numbers from search" do
        params = {
          "keywords" => "50",
        }

        query = described_class.new(
          finder_content_item:,
          params:,
        ).call

        expect(query).to include("q" => "50")
      end
    end
  end

  context "with a custom v2 serving config" do
    context "for Search API v1" do
      let(:use_v2_api) { false }
      let(:v2_serving_config) { "my-special-serving-config" }

      it "does not include a serving config query even if one is given" do
        expect(query).not_to have_key("serving_config")
      end
    end

    context "for Search API v2" do
      let(:use_v2_api) { true }

      context "if a custom serving config is given" do
        let(:v2_serving_config) { "my-special-serving-config" }

        it "includes a serving config query" do
          expect(query).to include("serving_config" => "my-special-serving-config")
        end
      end

      context "if no custom serving config is given" do
        let(:v2_serving_config) { nil }

        it "does not include a serving config query" do
          expect(query).not_to have_key("serving_config")
        end
      end
    end
  end

  context "with debug parameters" do
    let(:params) do
      {
        "debug" => "yes",
        "debug_serving_config" => "my-special-serving-config",
      }
    end

    context "for Search API v1" do
      let(:use_v2_api) { false }

      it "includes a debug query but no serving config one" do
        expect(query).to include("debug" => "yes")
        expect(query).not_to have_key("serving_config")
      end
    end

    context "for Search API v2" do
      let(:use_v2_api) { true }

      it "includes a serving config query but not a debug one" do
        expect(query).to include("serving_config" => "my-special-serving-config")
        expect(query).not_to have_key("debug")
      end
    end
  end

  context "without debug parameters" do
    it "does not include a debug or serving config query" do
      expect(query).not_to include("debug")
      expect(query).not_to include("serving_config")
    end
  end

  context "with A/B parameters" do
    let(:ab_params) do
      {
        test_one: "a",
        test_two: "b",
      }
    end

    it "includes an A/B query" do
      query = described_class.new(
        finder_content_item:,
        ab_params:,
      ).call

      expect(query).to include("ab_tests" => "test_one:a,test_two:b")
    end
  end

  context "with a base filter" do
    let(:filter) { { "document_type" => "news_story" } }

    it "includes fields prefixed with filter_" do
      expect(query).to include("filter_document_type" => "news_story")
    end
  end

  describe "#start" do
    it "starts at zero by default" do
      query = query_with_params({})

      expect(query["start"]).to be(0)
    end

    it "starts at zero when page param is zero" do
      query = query_with_params("page" => 0)

      expect(query["start"]).to be(0)
    end

    it "starts at zero when page param is nil" do
      query = query_with_params("page" => nil)

      expect(query["start"]).to be(0)
    end

    it "starts at zero when page param is empty" do
      query = query_with_params("page" => "")

      expect(query["start"]).to be(0)
    end

    it "starts at zero when page param is an array" do
      query = query_with_params("page" => %w[abc])

      expect(query["start"]).to be(0)
    end

    it "starts at zero when page param is an invalid string" do
      query = query_with_params("page" => "def")

      expect(query["start"]).to be(0)
    end

    it "is paginated" do
      query = query_with_params("page" => "10")

      expect(query["start"]).to be(13_500)
    end

    def query_with_params(params)
      described_class.new(
        finder_content_item:,
        params:,
      ).call
    end
  end
end
