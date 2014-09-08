require 'gds_api/test_helpers/content_api'

module CaseHelper
  include GdsApi::TestHelpers::ContentApi

  def stub_case_collection_api_request
    stub_request(:get, rummager_all_cases_url).to_return(
      body: all_cases_json,
    )

    stub_request(:get, rummager_merger_inquiry_cases_url).to_return(
      body: merger_inquiry_cases_json,
    )

    stub_request(:get, schema_url).to_return(
      body: schema_json,
    )
  end

  def stub_keyword_search_api_request
    stub_request(:get, rummager_keyword_search_url).to_return(
      body: keyword_search_results,
    )
  end

  def stub_finder_artefact_api_request
    artefact_data = artefact_for_slug('cma-cases').merge(cma_case_artefact)
    content_api_has_an_artefact('cma-cases', artefact_data)
  end

  def search_params(params = {})
    default_search_params.merge(params).to_a.map { |tuple|
      tuple.join("=")
    }.join("&")
  end

  def default_search_params
    {
      "count" => "1000",
      "fields" => cma_search_fields.join(","),
      "filter_document_type" => "cma_case",
    }
  end

  def cma_search_fields
    %w(
      title
      link
      description
      case_type
      case_state
      market_sector
      outcome_type
      opened_date
      closed_date
    )
  end

  def rummager_all_cases_url
    "#{Plek.current.find('search')}/unified_search.json?#{search_params}"
  end

  def rummager_merger_inquiry_cases_url
    params = {
      "filter_case_type[]" => "mergers",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def schema_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/schema.json"
  end

  def rummager_keyword_search_url
    params = {
      "q" => "keyword%20searchable",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def keyword_search_results
    %|{
      "results": [
        {
          "title": "Acme keyword searchable case",
          "opened_date": "2008-06-28",
          "closed_date": "2010-10-05",
          "summary": "Inquiry into making CMA cases keyword saerchable",
          "document_type": "cma_case",

          "market_sector": [{
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          }],
          "case_type": [{
            "value": "mergers",
            "label": "Mergers"
          }],
          "outcome_type": [{
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          }],
          "case_state": [{
            "value": "closed",
            "label": "Closed"
          }],

          "link": "/cma-cases/somewhat-unique-cma-case",
          "_id": "/cma-cases/somewhat-unique-cma-case"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def all_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",
          "document_type": "cma_case",

          "market_sector": [{
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          }],
          "case_type": [{
            "value": "mergers",
            "label": "Mergers"
          }],
          "outcome_type": [{
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          }],
          "case_state": [{
            "value": "closed",
            "label": "Closed"
          }],

          "link": "cma-cases/healthcorp-druginc-merger-inquiry",
          "_id": "cma-cases/healthcorp-druginc-merger-inquiry"
        },
        {
          "title": "Private healthcare market investigation",
          "opened_date": "2007-08-14",
          "closed_date": "2008-03-01",
          "summary": "Inquiry into the private healthcare market",
          "document_type": "cma_case",

          "market_sector": [{
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          }],
          "case_type": [{
            "value": "markets",
            "label": "Markets"
          }],
          "outcome_type": [{
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          }],
          "case_state": [{
            "value": "closed",
            "label": "Closed"
          }],

          "link": "cma-cases/private-healthcare-market-investigation",
          "_id": "cma-cases/private-healthcare-market-investigation"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def merger_inquiry_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "document_type": "cma_case",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",

          "market_sector": [{
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          }],
          "case_type": [{
            "value": "mergers",
            "label": "Mergers"
          }],
          "outcome_type": [{
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          }],
          "case_state": [{
            "value": "closed",
            "label": "Closed"
          }],

          "link": "cma-cases/healthcorp-druginc-merger-inquiry",
          "_id": "cma-cases/healthcorp-druginc-merger-inquiry"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
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

  def cma_case_artefact
    {
      :id => "http://contentapi.dev.gov.uk/cma-cases.json",
      :web_url => "http://finder-frontend.dev.gov.uk/cma-cases",
      :title => "Competition and Markets Authority cases",
      :format => "finder",
      :updated_at => "2014-06-26T13:44:57+01:00",
      :tags => [
        {
          :id => "http://contentapi.dev.gov.uk/tags/organisation/competition-and-markets-authority.json",
          :slug => "competition-and-markets-authority",
          :web_url => "http://www.dev.gov.uk/government/organisations/competition-and-markets-authority",
          :title => "Competition and Markets Authority ",
          :details => {
            :description => nil,
            :short_description => nil,
            :type => "organisation"
          },
          :content_with_tag => {
            :id => "http://contentapi.dev.gov.uk/with_tag.json?organisation=competition-and-markets-authority",
            :web_url => nil
          },
          :parent => nil
        }
      ]
    }
  end

  def select_filters(facets = {})
    within ".filter-form form" do
      facets.values.each do |value|
        check(value)
      end
      click_on "Filter results"
    end
  end
end

World(CaseHelper)
