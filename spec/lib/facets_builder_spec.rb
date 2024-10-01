require "spec_helper"

describe FacetsBuilder do
  include GovukContentSchemaExamples

  let(:option_select_facet_hash) do
    {
      "filterable": true,
      "key": "people",
      "type": "text",
      "allowed_values": [{ "value" => "me" }, { "value" => "you" }],
    }
  end
  let(:taxon_facet_hash) do
    {
      "key": "_unused",
      "keys": %w[
        level_one_taxon
        level_two_taxon
      ],
      "type": "taxon",
      "filterable": true,
    }
  end
  let(:date_facet_hash) do
    {
      "filterable": true,
      "key": "public_timestamp",
      "type": "date",
    }
  end
  let(:hidden_facet_hash) do
    {
      "filter_key": "hidden",
      "key": "topic",
      "type": "hidden",
      "filterable": true,
      "allowed_values": [{ "value" => "hiding" }],
    }
  end
  let(:checkbox_facet_hash) do
    {
      "key": "checkbox",
      "filter_key": "checkbox",
      "filter_value": "filter_value",
      "type": "checkbox",
      "filterable": true,
    }
  end
  let(:radio_facet_hash) do
    {
      "key": "content_store_document_type",
      "type": "radio",
      "filterable": true,
      "option_lookup": {
        "statistics_published": %w[
          statistics
        ],
      },
      "allowed_values": [
        { "value": "statistics_published" },
      ],
    }
  end
  let(:hidden_clearable_facet_hash) do
    {
      "filterable": true,
      "key": "manual",
      "type": "hidden_clearable",
      "allowed_values": [{ "value" => "my_manual" }],
    }
  end

  let(:detail_hash) do
    {
      "details" => {
        "facets" => [
          taxon_facet_hash,
          checkbox_facet_hash,
          radio_facet_hash,
          date_facet_hash,
          option_select_facet_hash,
          hidden_facet_hash,
          hidden_clearable_facet_hash,
        ],
        "sort" => sort_without_relevance,
      },
    }
  end

  let(:content_item_hash) do
    example_finder.merge(detail_hash).deep_stringify_keys
  end

  let(:content_item) do
    ContentItem.new(content_item_hash)
  end

  describe "facets" do
    subject(:facet) do
      described_class.new(content_item:, search_results: {}, value_hash: {}).facets.first
    end

    let(:detail_hash) do
      {
        "details" => {
          "facets" => [
            hash_under_test,
          ],
        },
      }
    end

    context "option_select_facet_hash facet" do
      let(:hash_under_test) do
        option_select_facet_hash
      end

      it "builds a option_select facet" do
        expect(facet).to be_a(OptionSelectFacet)
        expect(facet.key).to eq("people")
      end
    end

    context "taxon facet" do
      let(:hash_under_test) do
        taxon_facet_hash
      end

      it "builds a taxon facet" do
        expect(facet).to be_a(TaxonFacet)
        expect(facet.keys).to eq(%w[level_one_taxon level_two_taxon])
      end
    end

    context "date facet" do
      let(:hash_under_test) do
        date_facet_hash
      end

      it "builds a taxon facet" do
        expect(facet).to be_a(DateFacet)
        expect(facet.key).to eq("public_timestamp")
      end
    end

    context "hidden facet" do
      let(:hash_under_test) do
        hidden_facet_hash
      end

      it "builds a hidden facet" do
        expect(facet).to be_a(HiddenFacet)
        expect(facet.key).to eq("topic")
      end
    end

    context "checkbox facet" do
      let(:hash_under_test) do
        checkbox_facet_hash
      end

      it "builds a checkbox facet" do
        expect(facet).to be_a(CheckboxFacet)
        expect(facet.key).to eq("checkbox")
      end
    end

    context "radio facet" do
      let(:hash_under_test) do
        radio_facet_hash
      end

      it "builds a checkbox facet" do
        expect(facet).to be_a(RadioFacet)
        expect(facet.key).to eq("content_store_document_type")
      end
    end

    context "hidden_clearable facet" do
      let(:hash_under_test) do
        hidden_clearable_facet_hash
      end

      it "builds a checkbox facet" do
        expect(facet).to be_a(HiddenClearableFacet)
        expect(facet.key).to eq("manual")
      end
    end
  end

  describe "allowed values" do
    subject(:facet) do
      described_class.new(content_item:, search_results:, value_hash: {}).facets.first
    end

    let(:search_results) do
      {}
    end
    let(:rummager_params) do
      {
        count: 0,
        facet_people: "1500,examples:0,order:value.title",
      }
    end
    let(:rummager_url) { "#{Plek.find('search-api')}/search.json?#{rummager_params.to_query}" }

    let(:detail_hash) do
      {
        "details" => {
          "facets" => [
            hash_under_test,
          ],
        },
      }
    end

    context "The allowed values are in the content item hash" do
      let(:hash_under_test) do
        option_select_facet_hash
      end

      it "copies allowed values from the hash" do
        expect(facet.allowed_values).to eq([{ "value" => "me" }, { "value" => "you" }])
      end
    end

    context "The allowed values are in the registry" do
      let(:hash_under_test) do
        option_select_facet_hash.except(:allowed_values)
      end

      it "gets values from the registry" do
        stub_request(:get, rummager_url).to_return(body: people_search_api_results.to_json)
        expect(facet.allowed_values).to eq([{ "label" => "Cornelius Fudge", "value" => "cornelius-fudge" }, { "label" => "Rufus Scrimgeour", "value" => "rufus-scrimgeour" }])
      end
    end

    context "The allowed values are in the search results" do
      let(:hash_under_test) do
        {
          "filterable": true,
          "key": "specialist_sectors",
          "type": "text",
        }
      end
      let(:search_results) do
        specialist_sector_search_results.deep_stringify_keys
      end

      it "gets the allowed values from the search results" do
        expect(facet.allowed_values).to eq([{ "label" => "Import, export and customs for businesses", "value" => "business-tax/import-export" },
                                            { "label" => "Environmental permits", "value" => "environmental-management/environmental-permits" },
                                            { "label" => "Tax agent and adviser guidance", "value" => "dealing-with-hmrc/tax-agent-guidance" }])
      end
    end
  end

  def specialist_sector_search_results
    {
      "results": [],
      "facets": {
        "specialist_sectors": {
          "options": [
            {
              "value": {
                "content_id": "4bda0be5-3e65-4cc1-850c-0541e95a40ca",
                "link": "/topic/business-tax/import-export",
                "title": "Import, export and customs for businesses",
                "slug": "business-tax/import-export",
              },
              "documents": 1189,
            },
            {
              "value": {
                "content_id": "9d128765-269a-4e90-982c-833a30a352d3",
                "link": "/topic/environmental-management/environmental-permits",
                "title": "Environmental permits",
                "slug": "environmental-management/environmental-permits",
              },
              "documents": 950,
            },
            {
              "value": {
                "content_id": "c3133eb2-4d53-4905-88a2-d2e4547cc41e",
                "link": "/topic/dealing-with-hmrc/tax-agent-guidance",
                "title": "Tax agent and adviser guidance",
                "slug": "dealing-with-hmrc/tax-agent-guidance",
              },
              "documents": 868,
            },
          ],
        },
      },
    }
  end

  def people_search_api_results
    {
      "results": [],
      "facets": {
        "people": {
          "options": [{
            "value": {
              "title": "Cornelius Fudge",
              "slug": "cornelius-fudge",
            },
          },
                      {
                        "value": {
                          "title": "Rufus Scrimgeour",
                          "slug": "rufus-scrimgeour",
                        },
                      }],
        },
      },
    }
  end
end
