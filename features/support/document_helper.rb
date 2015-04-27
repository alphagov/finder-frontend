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

  def search_params(params = {})
    default_search_params.merge(params).to_a.map { |tuple|
      tuple.join("=")
    }.join("&")
  end

  def default_search_params
    {
      "count" => "1000",
      "fields" => mosw_search_fields.join(","),
      "filter_document_type" => "mosw_report",
    }
  end

  def mosw_search_fields
    %w(
      title
      link
      description
      public_timestamp
      walk_type
      place_of_origin
      date_of_introduction
      creator
    )
  end

  def rummager_all_documents_url
    params = {
      "order" => "-public_timestamp",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def rummager_hopscotch_walks_url
    params = {
      "filter_walk_type[]" => "hopscotch",
      "order" => "-public_timestamp",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def rummager_keyword_search_url
    params = {
      "q" => "keyword%20searchable",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def rummager_policy_search_url
    # This is manual for now, as the stub URL helpers are deeply tied to mosw examples
    # @TODO: Refactor the search_params/search_fields methods to be generic
    "#{Plek.current.find('search')}/unified_search.json?count=1000&fields=title,link,description,public_timestamp,is_historic,government_name,organisations,display_type&filter_policies%5B0%5D=benefits-reform&order=-public_timestamp"
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

  def select_filters(facets = {})
    within ".filter-form form" do
      facets.values.each do |value|
        check(value)
      end
      click_on "Filter results"
    end
  end
end

World(DocumentHelper)
