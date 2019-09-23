require "spec_helper"

describe FacetsBuilder do
  include GovukContentSchemaExamples

  let(:option_select_facet_hash) {
    {
      "filterable": true,
      "key": "people",
      "type": "text",
      "allowed_values": [{ "value" => "me" }, { "value" => "you" }],
    }
  }
  let(:taxon_facet_hash) {
    {
      "key": "_unused",
      "keys": %w[
            level_one_taxon
            level_two_taxon
          ],
      "type": "taxon",
      "filterable": true,
    }
  }
  let(:date_facet_hash) {
    {
      "filterable": true,
      "key": "public_timestamp",
      "type": "date",
    }
  }
  let(:hidden_facet_hash) {
    {
      "filter_key": "hidden",
      "key": "topic",
      "type": "hidden",
      "filterable": true,
      "allowed_values": [{ "value" => "hiding" }],
    }
  }
  let(:checkbox_facet_hash) {
    {
      "key": "checkbox",
      "filter_key": "checkbox",
      "filter_value": "filter_value",
      "type": "checkbox",
      "filterable": true,
    }
  }
  let(:radio_facet_hash) {
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
  }
  let(:hidden_clearable_facet_hash) {
    {
      "filterable": true,
      "key": "manual",
      "type": "hidden_clearable",
      "allowed_values": [{ "value" => "my_manual" }],
    }
  }
  let(:related_to_brexit_facet_hash) {
    {
      "key": "related_to_brexit",
      "filter_key": "all_part_of_taxonomy_tree",
      "filter_value": "d6c2de5d-ef90-45d1-82d4-5f2438369eea",
      "name": "Show only Brexit results",
      "type": "checkbox",
      "filterable": true,
    }
  }

  let(:detail_hash) {
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
  }

  let(:content_item_hash) {
    govuk_content_schema_example("finder").merge(detail_hash).deep_stringify_keys
  }

  let(:content_item) {
    ContentItem.new(content_item_hash)
  }

  describe "Remove brexit checkbox filter" do
    subject(:facets) do
      FacetsBuilder.new(content_item: content_item, search_results: {}, value_hash: value_hash).facets
    end
    let(:detail_hash) {
      {
        "details" => {
          "facets" => [
            taxon_facet_hash,
            checkbox_facet_hash,
            radio_facet_hash,
            related_to_brexit_facet_hash,
          ],
        },
      }
    }
    context "The page is filtered on the brexit topic" do
      let(:value_hash) {
        {
          "topic" => ContentItem::BREXIT_CONTENT_ID,
        }
      }
      it "contains no related to brexit taxon" do
        expect(facets).to_not include(an_object_satisfying { |facet| facet.key == "related_to_brexit" })
      end
    end
    context "The page is not filtered on the brexit topic" do
      let(:value_hash) {
        {
          related_to_brexit: ContentItem::BREXIT_CONTENT_ID,
        }
      }
      it "contains a related to brexit taxon" do
        expect(facets).to include(an_object_satisfying { |facet| facet.key == "related_to_brexit" })
      end
    end
  end

  describe "facets" do
    subject(:facet) do
      FacetsBuilder.new(content_item: content_item, search_results: {}, value_hash: {}).facets.first
    end
    let(:detail_hash) {
      {
        "details" => {
          "facets" => [
            hash_under_test,
          ],
        },
      }
    }
    context "option_select_facet_hash facet" do
      let(:hash_under_test) {
        option_select_facet_hash
      }
      it "builds a option_select facet" do
        expect(facet).to be_a(OptionSelectFacet)
        expect(facet.key).to eq("people")
      end
    end

    context "taxon facet" do
      let(:hash_under_test) {
        taxon_facet_hash
      }
      it "builds a taxon facet" do
        expect(facet).to be_a(TaxonFacet)
        expect(facet.keys).to eq(%w[level_one_taxon level_two_taxon])
      end
    end
    context "date facet" do
      let(:hash_under_test) {
        date_facet_hash
      }
      it "builds a taxon facet" do
        expect(facet).to be_a(DateFacet)
        expect(facet.key).to eq("public_timestamp")
      end
    end
    context "hidden facet" do
      let(:hash_under_test) {
        hidden_facet_hash
      }
      it "builds a hidden facet" do
        expect(facet).to be_a(HiddenFacet)
        expect(facet.key).to eq("topic")
      end
    end
    context "checkbox facet" do
      let(:hash_under_test) {
        checkbox_facet_hash
      }
      it "builds a checkbox facet" do
        expect(facet).to be_a(CheckboxFacet)
        expect(facet.key).to eq("checkbox")
      end
    end
    context "radio facet" do
      let(:hash_under_test) {
        radio_facet_hash
      }
      it "builds a checkbox facet" do
        expect(facet).to be_a(RadioFacet)
        expect(facet.key).to eq("content_store_document_type")
      end
    end
    context "hidden_clearable facet" do
      let(:hash_under_test) {
        hidden_clearable_facet_hash
      }
      it "builds a checkbox facet" do
        expect(facet).to be_a(HiddenClearableFacet)
        expect(facet.key).to eq("manual")
      end
    end
  end

  describe "allowed values" do
    subject(:facet) do
      FacetsBuilder.new(content_item: content_item, search_results: search_results, value_hash: {}).facets.first
    end

    let(:search_results) {
      {}
    }
    let(:rummager_params) {
      {
        count: 0,
        facet_people: "1500,examples:0,order:value.title",
      }
    }
    let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }

    let(:detail_hash) {
      {
        "details" => {
          "facets" => [
            hash_under_test,
          ],
        },
      }
    }
    context "The allowed values are in the content item hash" do
      let(:hash_under_test) {
        option_select_facet_hash
      }
      it "copies allowed values from the hash" do
        expect(facet.allowed_values).to eq([{ "value" => "me" }, { "value" => "you" }])
      end
    end
    context "The allowed values are in the registry" do
      let(:hash_under_test) {
        option_select_facet_hash.except(:allowed_values)
      }
      it "gets values from the registry" do
        stub_request(:get, rummager_url).to_return(body: people_search_api_results.to_json)
        expect(facet.allowed_values).to eq([{ "label" => "Cornelius Fudge", "value" => "cornelius-fudge" }, { "label" => "Rufus Scrimgeour", "value" => "rufus-scrimgeour" }])
      end
    end
    context "The allowed values are in the search results" do
      let(:hash_under_test) {
        {
          "filterable": true,
          "key": "topical_events",
          "type": "text",
        }
      }
      let(:search_results) {
        topical_events_search_results.deep_stringify_keys
      }
      it "gets the allowed values from the search results" do
        expect(facet.allowed_values).to eq([{ "label" => "First World War Centenary", "value" => "first-world-war-centenary" },
                                            { "label" => "Farming", "value" => "farming" },
                                            { "label" => "Ebola Virus Government Response (EVGR)", "value" => "ebola-virus-government-response" }])
      end
    end
  end

  def topical_events_search_results
    {
      "results": [],
      "facets": {
        "topical_events": {
          "options": [{
                        "value": {
                          "title": "First World War Centenary",
                          "slug": "first-world-war-centenary",
                        },
                      },
                      {
                        "value": {
                          "title": "Farming",
                          "slug": "farming",
                          "acronym": "Farming",
                        },
                      },
                      {
                        "value": {
                          "title": "Ebola Virus Government Response",
                          "slug": "ebola-virus-government-response",
                          "acronym": "EVGR",
                        },
                      }],
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
