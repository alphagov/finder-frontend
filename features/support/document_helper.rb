require_relative '../../lib/govuk_content_schema_examples'

module DocumentHelper
  include GovukContentSchemaExamples

  def stub_rummager_api_request
    stub_request(:get, rummager_all_documents_url).to_return(
      body: all_documents_json,
    )

    stub_request(:get, rummager_hopscotch_walks_url).to_return(
      body: hopscotch_reports_json,
    )
  end

  def stub_keyword_search_api_request
    stub_request(:get, rummager_keyword_search_url).to_return(
      body: keyword_search_results,
    )
  end

  def stub_rummager_api_request_with_government_results
    stub_request(:get, rummager_all_documents_url).to_return(
      body: government_documents_json,
    )
  end

  def stub_rummager_api_request_with_bad_data
    stub_request(:get, rummager_all_documents_url).to_return(
      body: documents_with_bad_data_json,
    )
  end

  def stub_rummager_api_request_with_policy_results
    stub_request(:get, rummager_policy_search_url).to_return(
      body: government_documents_json,
    )
  end

  def stub_rummager_api_request_with_policies_finder_results
    stub_request(:get, rummager_policies_finder_search_url).to_return(
      body: policies_documents_json,
    )
  end

  def content_store_has_mosw_reports_finder
    content_store_has_item('/mosw-reports', govuk_content_schema_example('finder').to_json)
  end

  def content_store_has_government_finder
    base_path = '/government/policies/benefits-reform'
    content_store_has_item(base_path,
      govuk_content_schema_example('finder').merge('base_path' => base_path).to_json
    )
  end

  def content_store_has_policy_finder
    base_path = '/government/policies/benefits-reform'
    content_store_has_item(base_path,
      govuk_content_schema_example('policy_area', 'policy').to_json
    )
  end

  def content_store_has_policies_finder
    base_path = '/government/policies'
    content_store_has_item(base_path,
      govuk_content_schema_example('policies_finder').to_json
    )
  end

  def search_params(params = {})
    default_search_params.merge(params).to_a.map { |tuple|
      tuple.join("=")
    }.join("&")
  end

  def stub_content_store_with_cma_cases_finder
    schema = govuk_content_schema_example("cma-cases", "finder")

    content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_rummager_with_cma_cases
    stub_request(:get, rummager_all_cma_case_documents_url).to_return(
      body: all_cma_case_documents_json,
    )

    stub_request(:get, rummager_filtered_cma_case_documents_url).to_return(
      body: filtered_cma_case_documents_json,
    )
  end

  def rummager_all_documents_url
    rummager_url(
      mosw_search_params.merge(
        "order" => "-public_timestamp",
      )
    )
  end

  def rummager_hopscotch_walks_url
    rummager_url(
      mosw_search_params.merge(
        "filter_walk_type" => ["hopscotch"],
        "order" => "-public_timestamp",
      )
    )
  end

  def rummager_keyword_search_url
    rummager_url(
      mosw_search_params.merge(
        "q" => "keyword searchable",
      )
    )
  end

  def rummager_policy_search_url
    rummager_url(
      policy_search_params.merge(
        "order" => "-public_timestamp",
      )
    )
  end

  def rummager_all_cma_case_documents_url
    rummager_url(
      cma_case_search_params.merge(
        "order" => "-public_timestamp",
      )
    )
  end

  def rummager_filtered_cma_case_documents_url
    rummager_url(
      cma_case_search_params.merge(
        "filter_opened_date" => "from:2015-02-02",
        "order" => "-public_timestamp",
      )
    )
  end

  def rummager_policies_finder_search_url
    "#{Plek.current.find('search')}/unified_search.json?count=1000&facet_organisations=1000,order:value.title&fields=title,link,description,public_timestamp,organisations&filter_document_type=policy&order=-public_timestamp"
  end

  def keyword_search_results
    %|{
      "results": [
        {
          "title": "Acme keyword searchable walk",
          "public_timestamp": "2010-10-06",
          "summary": "ACME researched a new type of silly walk",
          "document_type": "mosw_report",
          "walk_type": [{
            "value": "backwards",
            "label": "Backwards"
          }],
          "place_of_origin": [{
            "value": "scotland",
            "label": "Scotland"
          }],
          "creator": "Wile E Coyote",
          "date_of_introduction": "2014-08-28",
          "link": "mosw-reports/acme-keyword-searchable-walk",
          "_id": "mosw-reports/acme-keyword-searchable-walk"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def all_documents_json
    %|{
      "results": [
        {
          "title": "West London wobbley walk",
          "public_timestamp": "2014-11-25",
          "summary": "MOSW researched a new type of silly walk",
          "document_type": "mosw_report",
          "walk_type": [{
            "value": "backward",
            "label": "Backward"
          }],
          "place_of_origin": [{
            "value": "england",
            "label": "England"
          }],
          "creator": "Road Runner",
          "date_of_introduction": "2003-12-30",
          "link": "mosw-reports/west-london-wobbley-walk",
          "_id": "mosw-reports/west-london-wobbley-walk"
        },
        {
          "title": "The Gerry Anderson",
          "public_timestamp": "2010-10-06",
          "summary": "Rhyming slang for Dander, an Irish colloquialism for walk",
          "document_type": "mosw_report",
          "walk_type": [{
            "value": "hopscotch",
            "label": "Hopscotch"
          }],
          "place_of_origin": [{
            "value": "northern-ireland",
            "label": "Northern Ireland"
          }],
          "creator": "",
          "date_of_introduction": "1914-08-28",
          "link": "mosw-reports/the-gerry-anderson",
          "_id": "mosw-reports/the-gerry-anderson"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def government_documents_json
    %|{
      "results": [
        {
          "title": "Free computers for schools",
          "summary": "Giving all children access to a computer",
          "format": "news_article",
          "creator": "Dale Cooper",
          "public_timestamp": "2007-02-14T00:00:00.000+01:00",
          "is_historic": true,
          "display_type": "News Story",
          "organisations": [{
            "slug": "ministry-of-justice",
            "link": "/government/organisations/ministry-of-justice",
            "title": "Ministry of Justice",
            "acronym": "MoJ",
            "organisation_state": "live"
          }],
          "government_name": "2005 to 2010 Labour government",
          "link": "/government/policies/education/free-computers-for-schools",
          "_id": "/government/policies/education/free-computers-for-schools"
        },
        {
          "title": "An extra bank holiday per year",
          "public_timestamp": "2015-03-14T00:00:00.000+01:00",
          "summary": "We lost a day and found it again so everyone can get it off",
          "format": "news_article",
          "creator": "Dale Cooper",
          "is_historic": false,
          "organisations": [{
            "slug": "ministry-of-justice",
            "link": "/government/organisations/ministry-of-justice",
            "title": "Ministry of Justice",
            "acronym": "MoJ",
            "organisation_state": "live"
          }],
          "display_type": "News Story",
          "government_name": "2010 to 2015 Conservative and Liberal Democrat Coalition government",
          "link": "/government/policies/education/an-extra-bank-holiday-per-year",
          "_id": "/government/policies/education/an-extra-bank-holiday-per-year"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def policies_documents_json
    %|{
      "results": [
        {
          "title": "Education",
          "summary": "Education",
          "format": "policy",
          "creator": "Dale Cooper",
          "public_timestamp": "2007-02-14T00:00:00.000+01:00",
          "is_historic": true,
          "display_type": "Policy",
          "organisations": [{
            "slug": "ministry-of-justice",
            "link": "/government/organisations/ministry-of-justice",
            "title": "Ministry of Justice",
            "acronym": "MoJ",
            "organisation_state": "live"
          }],
          "government_name": "2005 to 2010 Labour government",
          "link": "/government/policies/education",
          "_id": "/government/policies/education"
        },
        {
          "title": "Afghanistan",
          "public_timestamp": "2015-03-14T00:00:00.000+01:00",
          "summary": "What the government is doing about Afghanistan",
          "format": "policy",
          "creator": "Dale Cooper",
          "is_historic": false,
          "organisations": [{
            "slug": "ministry-of-justice",
            "link": "/government/organisations/ministry-of-justice",
            "title": "Ministry of Justice",
            "acronym": "MoJ",
            "organisation_state": "live"
          }],
          "display_type": "Policy",
          "government_name": "2010 to 2015 Conservative and Liberal Democrat Coalition government",
          "link": "/government/policies/afghanistan",
          "_id": "/government/policies/afghanistan"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {
        "organisations": {
          "options": [
              {"value": {"title": "Ministry of Justice", "slug": "ministry-of-justice"}}
          ]
        }
      },
      "suggested_queries": []
    }|
  end

  def documents_with_bad_data_json
    %|{
      "results": [
        {
          "title": "West London wobbley walk",
          "public_timestamp": "2014-11-25",
          "summary": "MOSW researched a new type of silly walk",
          "document_type": "mosw_report",
          "walk_type": [{
            "value": "backward",
            "label": "Backward"
          }],
          "place_of_origin": [null],
          "creator": "Road Runner",
          "date_of_introduction": "2003-12-30",
          "link": "mosw-reports/west-london-wobbley-walk",
          "_id": "mosw-reports/west-london-wobbley-walk"
        },
        {
          "title": "The Gerry Anderson",
          "public_timestamp": "2010-10-06",
          "summary": "Rhyming slang for Dander, an Irish colloquialism for walk",
          "document_type": "mosw_report",
          "walk_type": [null],
          "place_of_origin": [{
            "value": "northern-ireland",
            "label": "Northern Ireland"
          }],
          "creator": "",
          "date_of_introduction": "1914-08-28",
          "link": "mosw-reports/the-gerry-anderson",
          "_id": "mosw-reports/the-gerry-anderson"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def hopscotch_reports_json
    %|{
      "results": [
        {
          "title": "The Gerry Anderson",
          "public_timestamp": "2010-10-06",
          "summary": "Rhyming slang for Dander, an Irish colloquialism for walk",
          "document_type": "mosw_report",
          "walk_type": [{
            "value": "hopscotch",
            "label": "Hopscotch"
          }],
          "place_of_origin": [{
            "value": "northern-ireland",
            "label": "Northern Ireland"
          }],
          "creator": "",
          "date_of_introduction": "1914-08-28",
          "link": "mosw-reports/the-gerry-anderson",
          "_id": "mosw-reports/the-gerry-anderson"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def all_cma_case_documents_json
    %|{
      "results": [
        {
          "title": "Big Beer Co / Salty Snacks Ltd merger inquiry",
          "public_timestamp": "2015-03-17T09:18:18+00:00",
          "summary": "The CMA is investigating the merging of Big Beer Co and Salty Snacks Ltd.",
          "document_type": "cma_case",
          "case_type": [{
            "value": "mergers",
            "label": "Mergers"
          }],
          "case_state": [{
            "value": "open",
            "label": "Open"
          }],
          "market_sector": [{
            "value": "food-manufacturing",
            "label": "Food manufacturing"
          }],
          "opened_date": "2015-02-14",
          "link": "cma-cases/big-beer-co-salty-snacks-ltd-merger",
          "_id": "cma-cases/big-beer-co-salty-snacks-ltd-merger"
        },
        {
          "title": "Bakery market investigation",
          "public_timestamp": "2015-01-06T10:34:17+00:00",
          "summary": "The CMA is investigation the supply and marketing of pizza-cakes in Great Britain.",
          "document_type": "cma_case",
          "case_type": [{
            "value": "markets",
            "label": "Markets"
          }],
          "case_state": [{
            "value": "open",
            "label": "Open"
          }],
          "market_sector": [{
            "value": "food-manufacturing",
            "label": "Food manufacturing"
          }],
          "opened_date": "2014-10-31",
          "link": "cma-cases/bakery-market-investigation",
          "_id": "cma-cases/bakery-market-investigation"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def filtered_cma_case_documents_json
    %|{
      "results": [
        {
          "title": "Big Beer Co / Salty Snacks Ltd merger inquiry",
          "public_timestamp": "2015-03-17T09:18:18+00:00",
          "summary": "The CMA is investigating the merging of Big Beer Co and Salty Snacks Ltd.",
          "document_type": "cma_case",
          "case_type": [{
            "value": "mergers",
            "label": "Mergers"
          }],
          "case_state": [{
            "value": "open",
            "label": "Open"
          }],
          "market_sector": [{
            "value": "food-manufacturing",
            "label": "Food manufacturing"
          }],
          "opened_date": "2015-02-14",
          "link": "cma-cases/big-beer-co-salty-snacks-ltd-merger",
          "_id": "cma-cases/big-beer-co-salty-snacks-ltd-merger"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def visit_filtered_finder(facets = {})
    visit finder_path("mosw-reports", facets)
  end

  def visit_cma_cases_finder
    visit finder_path("cma-cases")
  end

  def apply_date_filter
    fill_in("Opened after", with: "2015-02-02")
    click_on "Filter results"
  end

  def assert_cma_cases_are_filtered_by_date
    page.should have_content("1 case opened after 2 February 2015")

    within ".filtered-results .document:nth-child(1)" do
      page.should have_content("Big Beer Co / Salty Snacks Ltd merger inquiry")
    end
  end
end

World(DocumentHelper)
