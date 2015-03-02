require 'gds_api/test_helpers/content_store'
require_relative '../../lib/govuk_content_schema_examples'

module DocumentHelper
  include GdsApi::TestHelpers::ContentStore
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

  def content_store_has_mosw_reports_finder
    content_store_has_item('/mosw-reports', govuk_content_schema_example('finder').to_json)
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
      last_update
      walk_type
      place_of_origin
      date_of_introduction
      creator
    )
  end

  def rummager_all_documents_url
    params = {
      "order" => "-last_update",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{search_params(params)}"
  end

  def rummager_hopscotch_walks_url
    params = {
      "filter_walk_type[]" => "hopscotch",
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
          "title": "Acme keyword searchable walk",
          "last_update": "2010-10-06",
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
          "last_update": "2014-11-25",
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
          "last_update": "2010-10-06",
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

  def hopscotch_reports_json
    %|{
      "results": [
        {
          "title": "The Gerry Anderson",
          "last_update": "2010-10-06",
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
