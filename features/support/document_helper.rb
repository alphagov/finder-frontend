require_relative "../../spec/support/content_helper"
require_relative "../../spec/support/taxonomy_helper"
require_relative "../../spec/support/registry_helper"
require_relative "../../spec/support/fixtures_helper"
require "gds_api/test_helpers/email_alert_api"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/worldwide"

module DocumentHelper
  include FixturesHelper
  include GovukContentSchemaExamples
  include TaxonomySpecHelper
  include RegistrySpecHelper
  include GdsApi::TestHelpers::EmailAlertApi
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::Worldwide

  SEARCH_ENDPOINT = "#{Plek.find('search-api')}/search.json".freeze
  SEARCH_V2_ENDPOINT = "#{Plek.find('search-api-v2')}/search.json".freeze

  def stub_taxonomy_api_request
    stub_content_store_has_item("/", "links" => { "level_one_taxons" => [] })
  end

  def stub_response(query, body, including_v2: false)
    stub_request(:get, SEARCH_ENDPOINT).with(query:).to_return(body:)
    stub_request(:get, SEARCH_V2_ENDPOINT).with(query:).to_return(body:) if including_v2
  end

  def stub_search_api_request
    stub_response(hash_including(rummager_all_documents_params), all_documents_json, including_v2: true)
    stub_response(rummager_hopscotch_walks_params, hopscotch_reports_json, including_v2: true)
  end

  def stub_keyword_search_api_request(term)
    stub_response(hash_including(mosw_search_params.merge("q" => term)), keyword_search_results)
  end

  def stub_search_api_request_with_government_results
    stub_response(hash_including({}), government_documents_json)
  end

  def stub_search_api_request_with_query_param_no_results(query)
    stub_response(hash_including("q" => query), no_results_json)
  end

  def stub_search_api_request_with_10_government_results
    stub_response(rummager_10_documents_params, government_documents_json)
  end

  def stub_search_api_request_with_bad_data
    stub_response(rummager_all_documents_params, documents_with_bad_data_json)
  end

  def stub_search_api_request_with_10_government_results_page_2
    stub_response(rummager_10_documents_page_2_params, government_documents_page_2_json)
  end

  def stub_search_api_request_with_news_and_communication_results
    stub_response(
      hash_including(rummager_newest_news_and_communications_params),
      newest_news_and_communication_json,
    )
    stub_response(
      hash_including(rummager_popular_news_and_communications_params),
      popular_news_and_communication_json,
    )
  end

  def stub_search_api_request_with_policy_papers_results
    stub_response(hash_including(policy_papers_params), policy_and_engagement_results_json)
  end

  def stub_search_api_request_with_organisation_filter_all_content_results
    stub_response(
      hash_including("q" => "search-term", "filter_organisations" => %w[ministry-of-magic]),
      filtered_by_organisation_all_content_results_json,
      including_v2: true,
    )
  end

  def stub_search_api_request_with_query
    stub_response(
      hash_including("q" => "how to walk silly"),
      all_documents_json,
      including_v2: true,
    )
  end

  def stub_search_api_request_with_sorted_query
    stub_response(
      hash_including("q" => "dark gray all alone"),
      %({ "results": [], "total": 0, "start": 0}),
      including_v2: true,
    )
    stub_response(
      hash_including("q" => "dark gray all alone", "order" => "public_timestamp"), sorted_documents_json,
      including_v2: true
    )
  end

  def stub_search_api_request_with_filtered_query
    stub_response(
      hash_including("q" => "chandeliers flickering"),
      %({ "results": [], "total": 0, "start": 0}),
      including_v2: true,
    )

    stub_response(
      hash_including(
        "q" => "chandeliers flickering",
        "filter_all_part_of_taxonomy_tree" => %w[131313 1989],
        "filter_content_purpose_supergroup" => %w[research_and_statistics services],
        "filter_public_timestamp" => "from:1989-01-01,to:1989-12-13",
      ),
      filtered_documents_json,
      including_v2: true,
    )
  end

  def stub_search_api_request_with_misspelt_query
    stub_response(hash_including("q" => "drving"), spelling_suggestions_json, including_v2: true)
  end

  def stub_search_api_request_with_html_chars_query
    stub_response(hash_including("q" => "< ' & \""), no_results_json, including_v2: true)
  end

  def stub_search_api_request_with_manual_filter_all_content_results
    stub_response(
      hash_including("q" => "search-term", "filter_manual" => %w[how-to-be-a-wizard]),
      filtered_by_manual_all_content_results_json,
      including_v2: true,
    )
    stub_response(
      hash_including("q" => "search-term-updated", "filter_manual" => %w[how-to-be-a-wizard]),
      filtered_by_manual_all_content_results_json,
      including_v2: true,
    )
  end

  def stub_search_api_request_with_filtered_policy_papers_results
    stub_response(
      hash_including(
        policy_papers_params.merge(
          "filter_content_store_document_type" => %w[case_study impact_assessment policy_paper],
        ),
      ),
      policy_and_engagement_results_for_policy_papers_json,
    )
    stub_response(
      hash_including(
        policy_papers_params.merge(
          "filter_content_store_document_type" => %w[
            case_study closed_consultation consultation_outcome impact_assessment policy_paper
          ],
        ),
      ),
      policy_and_engagement_results_for_policy_papers_and_closed_consultations_json,
    )
  end

  def stub_search_api_request_with_research_and_statistics_results
    stub_response(
      hash_including(
        "filter_content_store_document_type" => %w[
          independent_report
          national_statistics
          official_statistics
          research
          research_for_development_output
          statistical_data_set
          statistics
          statistics_announcement
        ],
      ),
      statistics_results_for_statistics_json,
    )
  end

  def stub_search_api_request_with_statistics_results
    stub_response(
      hash_including(
        "filter_content_store_document_type" => %w[
          national_statistics
          official_statistics
          statistical_data_set
          statistics
        ],
      ),
      statistics_results_for_statistics_json,
    )
  end

  def stub_search_api_request_with_filtered_research_and_statistics_results
    Timecop.freeze(Time.zone.parse("2019-01-01").utc)
    stub_response(
      hash_including(
        "filter_format" => %w[statistics_announcement],
        "filter_release_timestamp" => "from:2019-01-01",
      ),
      upcoming_statistics_results_for_statistics_json,
    )
  end

  def stub_search_api_request_with_aaib_reports_results
    stub_response(hash_including({}), %({ "results": [], "total": 0, "start": 0}))
  end

  def stub_all_search_api_requests_with_news_and_communication_results
    stub_response(hash_including({}), newest_news_and_communication_json)
  end

  def stub_search_api_request_with_services_results
    stub_response(hash_including(rummager_alphabetical_services_params), alpabetical_services_json)
    stub_response(hash_including(rummager_popular_services_params), popular_services_json)
  end

  def stub_search_api_request_with_no_results
    stub_response(rummager_0_documents_params, %({ "results": [], "total": 0, "start": 0}))
  end

  def stub_search_api_request_with_422_response(page_number)
    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: rummager_document_other_page_search_params(page_number))
      .to_return(status: 422)
  end

  def stub_topical_events_api_request
    stub_response(
      hash_including({ filter_format: "topical_event", count: "1500" }),
      { results: [], total: 0, start: 0 }.to_json,
    )
  end

  def stub_world_locations_api_request
    stub_worldwide_api_has_locations(%w[azkaban tracy-island])
  end

  def content_store_has_mosw_reports_finder
    stub_content_store_has_item("/mosw-reports", example_finder.to_json)
  end

  def content_store_has_mosw_reports_finder_with_no_facets
    finder = example_finder
    finder["details"]["facets"] = []
    stub_content_store_has_item("/mosw-reports", finder.to_json)
  end

  def content_store_has_news_and_communications_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/news_and_communications_with_checkboxes.json"))

    stub_content_store_has_item("/search/news-and-communications", finder_fixture)
  end

  def content_store_has_government_finder
    base_path = "/government/policies/benefits-reform"
    finder = example_finder.merge("base_path" => base_path)
    finder["details"]["sort"] = [
      {
        "name": "Most viewed",
        "key": "-popularity",
      },
      {
        "name": "Relevance",
        "key": "-relevance",
        "default": true,
      },
    ]

    stub_content_store_has_item(base_path, finder.to_json)
  end

  def content_store_has_services_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/services.json"))

    stub_content_store_has_item("/search/services", finder_fixture)
  end

  def content_store_has_government_finder_with_10_items
    base_path = "/government/policies/benefits-reform"
    content_item = example_finder.merge("base_path" => base_path)
    content_item["details"]["default_documents_per_page"] = 10
    stub_content_store_has_item(base_path, content_item.to_json)
  end

  def content_store_has_statistics_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/statistics.json"))

    stub_content_store_has_item("/search/research-and-statistics", finder_fixture)
  end

  def content_store_has_aaib_reports_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/aaib_reports_example.json"))

    stub_content_store_has_item("/aaib-reports", finder_fixture)
  end

  def content_store_has_all_content_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/all_content.json"))

    stub_content_store_has_item("/search/all", finder_fixture)
  end

  def content_store_has_policy_and_engagement_finder
    finder_fixture = File.read(Rails.root.join("features/fixtures/policy_and_engagement.json"))

    stub_content_store_has_item("/search/policy-papers-and-consultations", finder_fixture)
  end

  def stub_content_store_with_cma_cases_finder
    schema = example_cma_cases_finder

    stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_content_store_with_a_taxon_tagged_finder
    schema = example_cma_cases_finder.merge(
      "links" => {
        "taxons" => [
          {
            "api_path" => "/api/content/business/competition-competition-act-cartels",
            "base_path" => "/business/competition-competition-act-cartels",
            "content_id" => "900ee60d-32ed-4dba-9834-09f54de01d5d",
            "document_type" => "taxon",
            "locale" => "en",
            "public_updated_at" => "2018-09-03T15:41:04Z",
            "schema_name" => "taxon",
            "title" => "Competition Act and cartels",
            "withdrawn": false,
            "details": {
              "internal_name" => "Competition Act and cartels [T]",
              "notes_for_editors" => "",
              "visible_to_departmental_editors": false,
            },
            "phase" => "live",
          },
        ],
      },
    )

    stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_rummager_with_cma_cases
    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: rummager_all_cma_case_documents_params)
      .to_return(body: all_cma_case_documents_json)

    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: rummager_filtered_cma_case_documents_params)
      .to_return(body: filtered_cma_case_documents_json)
  end

  def stub_content_store_with_cma_cases_finder_with_description
    schema = example_cma_cases_finder
      .merge("description" => "Find reports and updates on current and historical CMA investigations")

    stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_content_store_with_cma_cases_finder_with_no_index
    schema = example_cma_cases_finder
    schema["details"]["no_index"] = true

    stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_content_store_with_cma_cases_finder_with_metadata
    schema = example_cma_cases_finder.merge("from" => "An authority")

    stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_content_store_with_cma_cases_finder_for_supergroup_checkbox_filter
    schema = example_cma_cases_finder
    schema["details"]["facets"].map! do |facet|
      if facet["key"] == "case_state"
        {
          "value" => "open",
          "filter_value" => "open",
          "key" => "case_state",
          "name" => "Show open cases",
          "short_name" => "Open",
          "type" => "checkbox",
          "display_as_result_metadata" => false,
          "filterable" => true,
          "preposition" => "that is",
        }
      else
        facet
      end
    end
    schema["details"]["facets"] << stub_content_store_has_item(
      schema.fetch("base_path"),
      schema.to_json,
    )
  end

  def stub_rummager_with_cma_cases_for_supergroups_checkbox
    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: hash_including(rummager_all_cma_case_documents_params))
      .to_return(body: all_cma_case_documents_json)

    open_cma_case_documents_params =
      cma_case_search_params.merge(
        "filter_case_state" => "open",
        "order" => "-public_timestamp",
      )

    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: hash_including(open_cma_case_documents_params))
      .to_return(body: filtered_cma_case_documents_json)
  end

  def stub_rummager_with_cma_cases_for_supergroups_checkbox_and_date
    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: hash_including(rummager_all_cma_case_documents_params))
      .to_return(body: all_cma_case_documents_json)

    open_cma_case_documents_params = cma_case_search_params.merge(
      "filter_case_state" => "open",
      "order" => "-public_timestamp",
      "filter_closed_date" => "from:2015-11-01",
    )

    stub_request(:get, SEARCH_ENDPOINT)
      .with(query: hash_including(open_cma_case_documents_params))
      .to_return(body: filtered_cma_case_documents_json)
  end

  def rummager_all_documents_params
    mosw_search_params.merge("order" => "-public_timestamp")
  end

  def rummager_0_documents_params
    mosw_search_params_no_facets.merge(
      "order" => "-public_timestamp",
      "count" => 1500,
    )
  end

  def rummager_10_documents_params
    mosw_search_params.merge(
      "order" => "-public_timestamp",
      "count" => 10,
    )
  end

  def rummager_10_documents_page_2_params
    mosw_search_params.merge(
      "order" => "-public_timestamp",
      "count" => 10,
      "start" => 10,
    )
  end

  def rummager_hopscotch_walks_params
    mosw_search_params.merge(
      "filter_walk_type" => %w[hopscotch],
      "order" => "-public_timestamp",
    )
  end

  def rummager_newest_news_and_communications_params
    news_and_communications_search_params.merge(
      "order" => "-public_timestamp",
      "count" => "20",
    )
  end

  def rummager_popular_news_and_communications_params
    news_and_communications_search_params.merge(
      "order" => "-popularity",
      "count" => "20",
    )
  end

  def rummager_popular_services_params
    services_search_params.merge(
      "order" => "-popularity",
      "count" => "20",
    )
  end

  def rummager_alphabetical_services_params
    services_search_params.merge(
      "order" => "title",
      "count" => "20",
    )
  end

  def rummager_document_other_page_search_params(page_number)
    count_per_page = 10

    mosw_search_params.merge(
      "order" => "-public_timestamp",
      "count" => count_per_page,
      "start" => ((page_number - 1) * count_per_page),
    )
  end

  def rummager_all_cma_case_documents_params
    cma_case_search_params.merge("order" => "-public_timestamp")
  end

  def rummager_filtered_cma_case_documents_params
    cma_case_search_params.merge(
      "filter_closed_date" => "from:2015-11-01",
      "order" => "-public_timestamp",
    )
  end

  def keyword_search_results
    %({
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
    })
  end

  def all_documents_json
    %({
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
          "link": "/mosw-reports/west-london-wobbley-walk",
          "_id": "/mosw-reports/west-london-wobbley-walk"
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
          "link": "/mosw-reports/the-gerry-anderson",
          "_id": "/mosw-reports/the-gerry-anderson"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def sorted_documents_json
    %({
      "results": [
        {
          "title": "Loving him was red",
          "public_timestamp": "2012-10-22",
          "summary": "Losing him was blue like I'd never known",
          "document_type": "song",
          "link": "/red",
          "_id": "/red"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def filtered_documents_json
    %({
      "results": [
        {
          "title": "Death by a thousand cuts",
          "public_timestamp": "2019-08-23",
          "summary": "I can't pretend it's okay when it's not",
          "document_type": "song",
          "link": "/death-by-a-thousand-cuts",
          "_id": "/death-by-a-thousand-cuts"
        }
      ],
      "total": 1,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def no_results_json
    %({
      "results": [],
      "total": 0,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def spelling_suggestions_json
    %({
      "results": #{government_document_results_json},
      "total": 20,
      "start": 0,
      "facets": {},
      "suggested_queries": [{ "text": "driving", "highlighted": "<mark>driving</mark>" }]
    })
  end

  def government_documents_json
    %({
      "results": #{government_document_results_json},
      "total": 20,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def government_documents_page_2_json
    %({
      "results": #{government_document_results_json(5)},
      "total": 20,
      "start": 10,
      "facets": {},
      "suggested_queries": []
    })
  end

  def government_document_results_json(start_at = 0)
    results = []

    5.times do |n|
      results << [
        {
          "title" => "Document #{n + start_at}",
          "summary" => "Giving all children access to a computer",
          "format" => "news_article",
          "creator" => "Dale Cooper",
          "public_timestamp" => "2007-02-14T00:00:00.000+01:00",
          "is_historic" => true,
          "display_type" => "News Story",
          "organisations" => [{
            "slug" => "ministry-of-justice",
            "link" => "/government/organisations/ministry-of-justice",
            "title" => "Ministry of Justice",
            "acronym" => "MoJ",
            "organisation_state" => "live",
          }],
          "government_name" => "2005 to 2010 Labour government",
          "link" => "/government/policies/education/free-computers-for-schools",
          "_id" => "/government/policies/education/free-computers-for-schools",
        },
        {
          "title" => "Document #{n + 1 + start_at}",
          "public_timestamp" => "2015-03-14T00:00:00.000+01:00",
          "summary" => "We lost a day and found it again so everyone can get it off",
          "format" => "news_article",
          "creator" => "Dale Cooper",
          "is_historic" => false,
          "display_type" => "News Story",
          "organisations" => [{
            "slug" => "ministry-of-justice",
            "link" => "/government/organisations/ministry-of-justice",
            "title" => "Ministry of Justice",
            "acronym" => "MoJ",
            "organisation_state" => "live",
          }],
          "government_name" => "2010 to 2015 Conservative and Liberal Democrat Coalition government",
          "link" => "/government/policies/education/an-extra-bank-holiday-per-year",
          "_id" => "/government/policies/education/an-extra-bank-holiday-per-year",
        },
      ]
    end

    results.flatten.to_json
  end

  def newest_news_and_communication_json
    %({
      "results": [
        {
          "title": "News from Hogwarts",
          "link": "/news-from-hogwarts",
          "description": "Breaking wizard news from Hogwarts",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/news-from-hogwarts",
          "elasticsearch_type": "news_article",
          "document_type": "news_article"
        },
        {
          "title": "Press release from Hogwarts",
          "link": "/press-release-from-hogwarts",
          "description": "An important press release from Hogwarts",
          "public_timestamp": "2017-12-25T09:00:00Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/press-release-from-hogwarts",
          "elasticsearch_type": "press_release",
          "document_type": "press_release"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {
        "people": {
          "options": [
            {
              "value": {
                "slug": "harry-potter",
                "title": "Harry Potter",
                "content_id": "aca5d2de-1fef-45fe-a39d-6a779589d220",
                "link": "/people/harry-potter"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        },
        "organisations": {
          "options": [
            {
              "value": {
                "organisation_brand": "ministry-of-magic",
                "logo_formatted_title": "Ministry of Magic",
                "organisation_crest": "single-identity",
                "title": "Ministry of Magic",
                "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
                "link": "/organisations/academy-for-social-justice-commissioning",
                "analytics_identifier": "MM1",
                "slug": "ministry-of-magic",
                "public_timestamp": "2017-12-15T11:11:02.000+00:00",
                "organisation_type": "other",
                "organisation_state": "live"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        },
        "world_locations": {
          "options": [
            {
              "value": {
                "slug": "azkaban",
                "title": "Azkaban",
                "content_id": "db3c2a86-2060-4c37-b8a4-9e3c4e6c91e2",
                "link": "/world/azkaban"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        }
      },
      "suggested_queries": []
    })
  end

  def popular_news_and_communication_json
    %({
      "results": [
        {
          "title": "Press release from Hogwarts",
          "link": "/press-release-from-hogwarts",
          "description": "An important press release from Hogwarts",
          "public_timestamp": "2017-12-25T09:00:00Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/press-release-from-hogwarts",
          "elasticsearch_type": "press_release",
          "document_type": "press_release"
        },
        {
          "title": "News from Hogwarts",
          "link": "/news-from-hogwarts",
          "description": "Breaking wizard news from Hogwarts",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/news-from-hogwarts",
          "elasticsearch_type": "news_article",
          "document_type": "news_article"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {
        "people": {
          "options": [
            {
              "value": {
                "slug": "harry-potter",
                "title": "Harry Potter",
                "content_id": "aca5d2de-1fef-45fe-a39d-6a779589d220",
                "link": "/people/harry-potter"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        },
        "organisations": {
          "options": [
            {
              "value": {
                "organisation_brand": "ministry-of-magic",
                "logo_formatted_title": "Ministry of Magic",
                "organisation_crest": "single-identity",
                "title": "Ministry of Magic",
                "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
                "link": "/organisations/academy-for-social-justice-commissioning",
                "analytics_identifier": "MM1",
                "slug": "ministry-of-magic",
                "public_timestamp": "2017-12-15T11:11:02.000+00:00",
                "organisation_type": "other",
                "organisation_state": "live"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        },
        "world_locations": {
          "options": [
            {
              "value": {
                "slug": "azkaban",
                "title": "Azkaban",
                "content_id": "db3c2a86-2060-4c37-b8a4-9e3c4e6c91e2",
                "link": "/world/azkaban"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        }
      },
      "suggested_queries": []
    })
  end

  def alpabetical_services_json
    %({
      "results": [
        {
          "title": "Apply for your full broomstick licence",
          "link": "apply-for-your-full-broomstick-licence",
          "description": "How to get your full broomstick licence once you've passed your broomstick test",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/news-from-hogwarts",
          "elasticsearch_type": "transaction",
          "document_type": "transaction"
        },
        {
          "title": "Register a spell",
          "link": "/register-a-spell",
          "description": "Register a magical spell",
          "description_with_highlighting": "Register a magical spell",
          "public_timestamp": "2017-12-25T09:00:00Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/register-a-spell",
          "elasticsearch_type": "transaction",
          "document_type": "transaction"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {
        "organisations": {
          "options": [
            {
              "value": {
                "organisation_brand": "ministry-of-magic",
                "logo_formatted_title": "Ministry of Magic",
                "organisation_crest": "single-identity",
                "title": "Ministry of Magic",
                "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
                "link": "/organisations/academy-for-social-justice-commissioning",
                "analytics_identifier": "MM1",
                "slug": "ministry-of-magic",
                "public_timestamp": "2017-12-15T11:11:02.000+00:00",
                "organisation_type": "other",
                "organisation_state": "live"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        }
      },
      "suggested_queries": []
    })
  end

  def popular_services_json
    %({
      "results": [
        {
          "title": "Register a spell",
          "link": "/register-a-spell",
          "description": "Register a magical spell",
          "description_with_highlighting": "Register a magical spell",
          "public_timestamp": "2017-12-25T09:00:00Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/register-a-spell",
          "elasticsearch_type": "transaction",
          "document_type": "transaction"
        },
        {
          "title": "Apply for your full broomstick licence",
          "link": "apply-for-your-full-broomstick-licence",
          "description": "How to get your full broomstick licence once you've passed your broomstick test",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "4bc72a8b-6011-457a-87e0-06dbb427cf36"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/news-from-hogwarts",
          "elasticsearch_type": "transaction",
          "document_type": "transaction"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {
        "organisations": {
          "options": [
            {
              "value": {
                "organisation_brand": "ministry-of-magic",
                "logo_formatted_title": "Ministry of Magic",
                "organisation_crest": "single-identity",
                "title": "Ministry of Magic",
                "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
                "link": "/organisations/academy-for-social-justice-commissioning",
                "analytics_identifier": "MM1",
                "slug": "ministry-of-magic",
                "public_timestamp": "2017-12-15T11:11:02.000+00:00",
                "organisation_type": "other",
                "organisation_state": "live"
              },
              "documents": 2
            }
          ],
          "documents_with_no_value": 0,
          "total_options": 2,
          "missing_options": 0,
          "scope": "exclude_field_filter"
        }
      },
      "suggested_queries": []
    })
  end

  def documents_with_bad_data_json
    %({
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
    })
  end

  def hopscotch_reports_json
    %({
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
    })
  end

  def all_cma_case_documents_json
    %({
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
            "value": "closed",
            "label": "Closed"
          }],
          "market_sector": [{
            "value": "food-manufacturing",
            "label": "Food manufacturing"
          }],
          "opened_date": "2015-02-14",
          "closed_date": "2016-02-14",
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
            "value": "closed",
            "label": "Closed"
          }],
          "market_sector": [{
            "value": "food-manufacturing",
            "label": "Food manufacturing"
          }],
          "opened_date": "2014-10-31",
          "closed_date": "2015-10-31",
          "link": "cma-cases/bakery-market-investigation",
          "_id": "cma-cases/bakery-market-investigation"
        }
      ],
      "total": 2,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    })
  end

  def filtered_cma_case_documents_json
    %({
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
    })
  end

  def policy_and_engagement_results_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        },
        {
          "title": "Proposed changes to magic tournaments",
          "link": "proposed-changes-to-magic-tournaments",
          "description": "Proposed changes to magic tournaments",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/proposed-changes-to-magic-tournaments",
          "elasticsearch_type": "open_consultation",
          "document_type": "open_consultation"
        },
        {
          "title": "New platform at Hogwarts for the express train",
          "link": "new-platform-at-hogwarts-for-the-express-train",
          "description": "New platform at Hogwarts for the express train",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/new-platform-at-hogwarts-for-the-express-train",
          "elasticsearch_type": "closed_consultation",
          "document_type": "closed_consultation"
        },
        {
          "title": "Installation of double glazing at Hogwarts",
          "link": "installation-of-double-glazing-at-hogwarts",
          "description": "Installation of double glazing at Hogwarts",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/installation-of-double-glazing-at-hogwarts",
          "elasticsearch_type": "consultation_outcome",
          "document_type": "consultation_outcome"
        }
      ],
      "total": 4,
      "start": 0,
      "suggested_queries": []
    })
  end

  def policy_and_engagement_results_for_policy_papers_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        }
      ],
      "total": 1,
      "start": 0,
      "suggested_queries": []
    })
  end

  def policy_and_engagement_results_for_policy_papers_and_closed_consultations_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        },
        {
          "title": "New platform at Hogwarts for the express train",
          "link": "new-platform-at-hogwarts-for-the-express-train",
          "description": "New platform at Hogwarts for the express train",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/new-platform-at-hogwarts-for-the-express-train",
          "elasticsearch_type": "closed_consultation",
          "document_type": "closed_consultation"
        },
        {
          "title": "Installation of double glazing at Hogwarts",
          "link": "installation-of-double-glazing-at-hogwarts",
          "description": "Installation of double glazing at Hogwarts",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/installation-of-double-glazing-at-hogwarts",
          "elasticsearch_type": "consultation_outcome",
          "document_type": "consultation_outcome"
        }
      ],
      "total": 3,
      "start": 0,
      "suggested_queries": []
    })
  end

  def statistics_results_for_statistics_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        },
        {
          "title": "New platform at Hogwarts for the express train",
          "link": "new-platform-at-hogwarts-for-the-express-train",
          "description": "New platform at Hogwarts for the express train",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/new-platform-at-hogwarts-for-the-express-train",
          "elasticsearch_type": "closed_consultation",
          "document_type": "closed_consultation"
        },
        {
          "title": "Installation of double glazing at Hogwarts",
          "link": "installation-of-double-glazing-at-hogwarts",
          "description": "Installation of double glazing at Hogwarts",
          "public_timestamp": "2018-11-16T11:11:42Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/installation-of-double-glazing-at-hogwarts",
          "elasticsearch_type": "consultation_outcome",
          "document_type": "consultation_outcome"
        }
      ],
      "total": 3,
      "start": 0,
      "suggested_queries": []
    })
  end

  def upcoming_statistics_results_for_statistics_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        }
      ],
      "total": 1,
      "start": 0,
      "suggested_queries": []
    })
  end

  def filtered_by_organisation_all_content_results_json
    %({
      "results": [
        {
          "title": "Restrictions on usage of spells within school grounds",
          "link": "/restrictions-on-usage-of-spells-within-school-grounds",
          "description": "Restrictions on usage of spells within school grounds",
          "description_with_highlighting": "Restrictions on usage of spells within school grounds",
          "public_timestamp": "2017-12-30T10:00:00Z",
          "part_of_taxonomy_tree": [
            "622e9691-4b4f-4e9c-bce1-098b0c4f5ee2"
          ],
          "organisations": [
            {
              "organisation_crest": "single-identity",
              "acronym": "MOM",
              "link": "/organisations/ministry-of-magic",
              "analytics_identifier": "MM1",
              "public_timestamp": "2017-12-15T11:11:02.000+00:00",
              "organisation_brand": "ministry-of-magic",
              "logo_formatted_title": "Ministry of Magic",
              "title": "Ministry of Magic",
              "content_id": "92881ac6-2804-4522-bf48-cf8c781c98bf",
              "slug": "ministry-of-magic",
              "organisation_type": "other",
              "organisation_state": "live"
            }
          ],
          "index": "govuk",
          "es_score": null,
          "_id": "/restrictions-on-usage-of-spells-within-school-grounds",
          "elasticsearch_type": "policy_paper",
          "document_type": "policy_paper"
        }
      ],
      "total": 1,
      "start": 0,
      "suggested_queries": [],
      "facets": {
        "organisations": {
          "options": [
            {"value": {"title": "Ministry of Magic", "slug": "ministry-of-magic"}}
          ]
        }
      }
    })
  end

  def filtered_by_manual_all_content_results_json
    %({
      "results": [
        {
          "title": "Choosing your wand",
          "link": "/choosing-your-wand",
          "description": "Choosing your wand - a practical guide",
          "_id": "/choosing-your-wand"
        }
      ],
      "total": 1,
      "start": 0,
      "suggested_queries": [],
      "facets": {
        "manual": [
          {
            "title": "Choosing your wand",
            "_id": "/choosing-your-wand"
          }
        ]
      }
    })
  end

  def visit_filtered_finder(facets = {})
    visit finder_path("mosw-reports", facets)
  end

  def visit_cma_cases_finder
    visit finder_path("cma-cases")
  end

  def apply_date_filter
    fill_in("Closed after", with: "2015-11-01")
    within ".js-live-search-fallback" do
      click_on "Filter results"
    end
  end

  def assert_cma_cases_are_filtered_by_date
    expect(page).to have_content("1 case")
    expect(page).to have_content("Closed After")
    expect(page).to have_content("1 November 2015")

    within ".finder-results .gem-c-document-list__item:nth-child(1)" do
      expect(page).to have_content("Big Beer Co / Salty Snacks Ltd merger inquiry")
    end
  end
end

World(DocumentHelper)
