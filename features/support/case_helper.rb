require 'gds_api/test_helpers/content_store'

module CaseHelper
  include GdsApi::TestHelpers::ContentStore

  def stub_case_collection_api_request
    stub_request(:get, rummager_all_cases_url).to_return(
      body: all_cases_json,
    )

    stub_request(:get, rummager_merger_inquiry_cases_url).to_return(
      body: merger_inquiry_cases_json,
    )
  end

  def stub_keyword_search_api_request
    stub_request(:get, rummager_keyword_search_url).to_return(
      body: keyword_search_results,
    )
  end

  def stub_finder_content_item_request
    content_store_has_item('/cma-cases', cma_cases_content_item)
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
      last_update
      case_type
      case_state
      market_sector
      outcome_type
      opened_date
      closed_date
    )
  end

  def rummager_all_cases_url
    params = {
      "order" => "-last_update",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def rummager_merger_inquiry_cases_url
    params = {
      "filter_case_type[]" => "mergers",
      "order" => "-last_update",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
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
          "last_update": "2010-10-06",
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

          "link": "cma-cases/somewhat-unique-cma-case",
          "_id": "cma-cases/somewhat-unique-cma-case"
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
          "last_update": "2005-03-01",
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
          "last_update": "2008-03-04",
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
          "last_update": "2004-03-04",
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

  def fixtures_path
    File.expand_path(File.dirname(__FILE__)) + "/../fixtures"
  end

  def cma_cases_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_content_item.json"))
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
