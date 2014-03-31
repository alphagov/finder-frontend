module CaseHelper
  def stub_case_collection_api_request
    stub_request(:get, finder_api_all_cases_url).to_return(
      body: all_cases_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    stub_request(:get, finder_api_merger_inquiry_cases_url).to_return(
      body: merger_inquiry_cases_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    stub_request(:get, finder_api_schema_url).to_return(
      body: schema_json,
      headers: { 'Content-Type' => 'application/json' }
    )

  end

  def finder_api_all_cases_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/documents.json"
  end

  def finder_api_merger_inquiry_cases_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/documents.json?case_type[]=mergers"
  end

  def finder_api_schema_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/schema.json"
  end

  def all_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "slug": "cma-cases/healthcorp-druginc-merger-inquiry",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "mergers",
            "label": "Mergers"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        },
        {
          "title": "Private healthcare market investigation",
          "slug": "cma-cases/private-healthcare-market-investigation",
          "opened_date": "2007-08-14",
          "closed_date": "2008-03-01",
          "summary": "Inquiry into the private healthcare market",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "markets",
            "label": "Markets"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        }
      ]
    }|
  end

  def merger_inquiry_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "slug": "cma-cases/healthcorp-druginc-merger-inquiry",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "mergers",
            "label": "Mergers"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        }
      ]
    }|
  end

  def schema_json
    %|{
        "slug": "cma-cases",
        "name": "Competition and Markets Authority cases",
        "document_noun": "case",
        "facets": [
          {
              "key": "case_type",
              "name": "Case type",
              "type": "multi-select",
              "include_blank": "All case types",
              "preposition": "of type",
              "allowed_values": [
                {"label": "CA98 and civil cartels", "value": "ca98-and-civil-cartels"},
                {"label": "Criminal cartels", "value": "criminal-cartels"},
                {"label": "Markets", "value": "markets"},
                {"label": "Mergers", "value": "mergers"}
              ]
          },

          {
            "key": "case_state",
            "name": "Case state",
            "type": "single-select",
            "include_blank": false,
            "preposition": "which are",
            "allowed_values": [
              {"label": "Open", "value": "open"},
              {"label": "Closed", "value": "closed"},
              {"label": "All", "value": "", "non_described": true }
            ]
          },

          {
            "key": "market_sector",
            "name": "Market sector",
            "type": "multi-select",
            "include_blank": false,
            "preposition": "about",
            "allowed_values": [
              {"label": "Agriculture, environment and natural resources", "value": "agriculture-environment-and-natural-resources"},
              {"label": "Aerospace", "value": "aerospace"},
              {"label": "Building and construction", "value": "building-and-construction"},
              {"label": "Chemicals", "value": "chemicals"},
              {"label": "Clothing, footwear and fashion", "value": "clothing-footwear-and-fashion"},
              {"label": "Communications", "value": "communications"},
              {"label": "Defence", "value": "defence"}
            ]
          },

          {
            "key": "outcome_type",
            "name": "Outcome",
            "type": "multi-select",
            "include_blank": false,
            "preposition": "with outcome",
            "allowed_values": [
              {"label": "CA98 - no grounds for action/non-infringement", "value": "ca98-no-grounds-for-action-non-infringement"},
              {"label": "CA98 - infringement Chapter I", "value": "ca98-infringement-chapter-i"},
              {"label": "CA98 - infringement Chapter II", "value": "ca98-infringement-chapter-ii"},
              {"label": "CA98 - administrative priorities", "value": "ca98-administrative-priorities"}
            ]
          }
        ]
      }
    |
  end

  def select_filters(facets = {})
    within ".facet-menu" do
      facets.values.each do |value|
        check(value)
      end
      click_on "Filter results"
    end
  end
end

World(CaseHelper)
