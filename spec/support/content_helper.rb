# Include this module to get access to the GOVUK Content Schema examples in the
# tests.
require "govuk_schemas/example"
require "gds_api/test_helpers/content_store"

module GovukContentSchemaExamples
  extend ActiveSupport::Concern

  included do
    include GdsApi::TestHelpers::ContentStore

    def example_finder
      finder = GovukSchemas::RandomExample.for_schema(frontend_schema: "finder")
      finder["schema_name"] = "finder"
      finder["document_type"] = "finder"
      finder["base_path"] = "/mosw-reports"
      finder["title"] = "Ministry of Silly Walks reports"
      finder["details"] = {
        "document_noun" => "report",
        "filter" => {
          "document_type" => "mosw_report",
        },
        "show_summaries" => true,
        "summary" => "The Ministry of Silly Walks researchs silly walks being developed by the British public",
        "sort" => [
          {
            "key" => "-public_timestamp",
            "name" => "Recently published",
            "default" => true,
          },
          {
            "key" => "-popularity",
            "name" => "Most popular",
          },
          {
            "key" => "-relevance",
            "name" => "Most relevant",
          },
        ],
        "facets" => [
          {
            "key" => "walk_type",
            "name" => "Walk type",
            "type" => "text",
            "preposition" => "of type",
            "display_as_result_metadata" => true,
            "filterable" => true,
            "allowed_values" => [
              {
                "value" => "backward",
                "label" => "Backward",
              },
              {
                "value" => "hopscotch",
                "label" => "Hopscotch",
              },
              {
                "value" => "start-and-stop",
                "label" => "Start-and-stop",
              },
            ],
          },
          {
            "key" => "place_of_origin",
            "name" => "Place of origin",
            "type" => "text",
            "preposition" => "from",
            "display_as_result_metadata" => true,
            "filterable" => true,
            "allowed_values" => [
              {
                "value" => "england",
                "label" => "England",
              },
              {
                "value" => "northern-ireland",
                "label" => "Northern Ireland",
              },
              {
                "value" => "scotland",
                "label" => "Scotland",
              },
              {
                "value" => "wales",
                "label" => "Wales",
              },
            ],
          },
          {
            "key" => "date_of_introduction",
            "name" => "Date of Introduction",
            "short_name" => "Introduced",
            "type" => "date",
            "preposition" => "introduced",
            "display_as_result_metadata" => true,
            "filterable" => false,
          },
          {
            "key" => "creator",
            "name" => "Creator",
            "type" => "text",
            "filterable" => false,
            "display_as_result_metadata" => false,
          },
        ],
      }
      finder["links"] = {
        "organisations" => [
          {
            "content_id" => "3338f283-64a1-4062-842e-677f520c1f15",
            "title" => "Ministry of Silly Walks",
            "api_path" => "/api/content/government/organisations/ministry-of-silly-walks",
            "base_path" => "/government/organisations/ministry-of-silly-walks",
            "api_url" => "https://www.gov.uk/api/content/government/organisations/government/organisations/ministry-of-silly-walks",
            "web_url" => "https://www.gov.uk/government/organisations/government/organisations/ministry-of-silly-walks",
            "locale" => "en",
          },
        ],
        "related" => [],
        "email_alert_signup" => [
          {
            "content_id" => "5c35b119-aebc-4ec8-9413-370bd01c24b3",
            "title" => "Ministry of Silly Walks reports",
            "api_path" => "/api/content/mosw-reports/email-signup",
            "base_path" => "/mosw-reports/email-signup",
            "api_url" => "https://www.gov.uk/api/content/mosw-reports/email-signup",
            "web_url" => "https://www.gov.uk/mosw-reports/email-signup",
            "locale" => "en",
          },
        ],
        "available_translations" => [
          {
            "content_id" => "23ec51f6-b1a1-41a7-97bc-59e18041e2e7",
            "title" => "Ministry of Silly Walks reports",
            "api_path" => "/api/contnet/mosw-reports",
            "base_path" => "/mosw-reports",
            "api_url" => "https://www.gov.uk/api/content/mosw-reports",
            "web_url" => "https://www.gov.uk/mosw-reports",
            "locale" => "en",
          },
        ],
      }
      finder
    end

    def example_cma_cases_finder
      finder = GovukSchemas::RandomExample.for_schema(frontend_schema: "finder")
      finder["schema_name"] = "finder"
      finder["document_type"] = "finder"
      finder["base_path"] = "/cma-cases"
      finder["title"] = "Competition and Markets Authority cases"
      finder["details"] = {
        "beta" => false,
        "document_noun" => "case",
        "facets" => [
          {
            "allowed_values" => [
              {
                "label" => "CA98 and civil cartels",
                "value" => "ca98-and-civil-cartels",
              },
              {
                "label" => "Competition disqualification",
                "value" => "competition-disqualification",
              },
              {
                "label" => "Criminal cartels",
                "value" => "criminal-cartels",
              },
              {
                "label" => "Markets",
                "value" => "markets",
              },
              {
                "label" => "Mergers",
                "value" => "mergers",
              },
              {
                "label" => "Consumer enforcement",
                "value" => "consumer-enforcement",
              },
              {
                "label" => "Regulatory references and appeals",
                "value" => "regulatory-references-and-appeals",
              },
              {
                "label" => "Reviews of orders and undertakings",
                "value" => "review-of-orders-and-undertakings",
              },
            ],
            "display_as_result_metadata" => true,
            "filterable" => true,
            "key" => "case_type",
            "name" => "Case type",
            "preposition" => "of type",
            "type" => "text",
          },
          {
            "allowed_values" => [
              {
                "label" => "Open",
                "value" => "open",
              },
              {
                "label" => "Closed",
                "value" => "closed",
              },
            ],
            "display_as_result_metadata" => true,
            "filterable" => true,
            "key" => "case_state",
            "name" => "Case state",
            "preposition" => "which are",
            "type" => "text",
          },
          {
            "allowed_values" => [
              {
                "label" => "Aerospace",
                "value" => "aerospace",
              },
              {
                "label" => "Agriculture, environment and natural resources",
                "value" => "agriculture-environment-and-natural-resources",
              },
              {
                "label" => "Building and construction",
                "value" => "building-and-construction",
              },
              {
                "label" => "Chemicals",
                "value" => "chemicals",
              },
              {
                "label" => "Clothing, footwear and fashion",
                "value" => "clothing-footwear-and-fashion",
              },
              {
                "label" => "Communications",
                "value" => "communications",
              },
              {
                "label" => "Defence",
                "value" => "defence",
              },
              {
                "label" => "Distribution and service industries",
                "value" => "distribution-and-service-industries",
              },
              {
                "label" => "Electronics",
                "value" => "electronics-industry",
              },
              {
                "label" => "Energy",
                "value" => "energy",
              },
              {
                "label" => "Engineering",
                "value" => "engineering",
              },
              {
                "label" => "Financial services",
                "value" => "financial-services",
              },
              {
                "label" => "Fire, police and security",
                "value" => "fire-police-and-security",
              },
              {
                "label" => "Food manufacturing",
                "value" => "food-manufacturing",
              },
              {
                "label" => "Giftware, jewellery and tableware",
                "value" => "giftware-jewellery-and-tableware",
              },
              {
                "label" => "Healthcare and medical equipment",
                "value" => "healthcare-and-medical-equipment",
              },
              {
                "label" => "Household goods, furniture and furnishings",
                "value" => "household-goods-furniture-and-furnishings",
              },
              {
                "label" => "Mineral extraction, mining and quarrying",
                "value" => "mineral-extraction-mining-and-quarrying",
              },
              {
                "label" => "Motor industry",
                "value" => "motor-industry",
              },
              {
                "label" => "Oil and gas refining and petrochemicals",
                "value" => "oil-and-gas-refining-and-petrochemicals",
              },
              {
                "label" => "Paper printing and packaging",
                "value" => "paper-printing-and-packaging",
              },
              {
                "label" => "Pharmaceuticals",
                "value" => "pharmaceuticals",
              },
              {
                "label" => "Public markets",
                "value" => "public-markets",
              },
              {
                "label" => "Recreation and leisure",
                "value" => "recreation-and-leisure",
              },
              {
                "label" => "Retail and wholesale",
                "value" => "retail-and-wholesale",
              },
              {
                "label" => "Telecommunications",
                "value" => "telecommunications",
              },
              {
                "label" => "Textiles",
                "value" => "textiles",
              },
              {
                "label" => "Transport",
                "value" => "transport",
              },
              {
                "label" => "Utilities",
                "value" => "utilities",
              },
            ],
            "display_as_result_metadata" => true,
            "filterable" => true,
            "key" => "market_sector",
            "name" => "Market sector",
            "preposition" => "about",
            "type" => "text",
          },
          {
            "allowed_values" => [
              {
                "label" => "CA98 - no grounds for action",
                "value" => "ca98-no-grounds-for-action-non-infringement",
              },
              {
                "label" => "CA98 - infringement Chapter I",
                "value" => "ca98-infringement-chapter-i",
              },
              {
                "label" => "CA98 - infringement Chapter II",
                "value" => "ca98-infringement-chapter-ii",
              },
              {
                "label" => "CA98 - administrative priorities",
                "value" => "ca98-administrative-priorities",
              },
              {
                "label" => "CA98 - commitments",
                "value" => "ca98-commitment",
              },
              {
                "label" => "Competition disqualification - order granted",
                "value" => "competition-disqualification-order-granted",
              },
              {
                "label" => "Competition disqualification - undertaking given",
                "value" => "competition-disqualification-undertaking-given",
              },
              {
                "label" => "Competition disqualification - no order granted or undertaking given",
                "value" => "competition-disqualification-no-order-granted-or-undertaking-given",
              },
              {
                "label" => "Criminal cartels - verdict",
                "value" => "criminal-cartels-verdict",
              },
              {
                "label" => "Markets - phase 1 no enforcement action",
                "value" => "markets-phase-1-no-enforcement-action",
              },
              {
                "label" => "Markets - phase 1 undertakings in lieu of reference",
                "value" => "markets-phase-1-undertakings-in-lieu-of-reference",
              },
              {
                "label" => "Markets - phase 1 referral",
                "value" => "markets-phase-1-referral",
              },
              {
                "label" => "Mergers - phase 1 clearance",
                "value" => "mergers-phase-1-clearance",
              },
              {
                "label" => "Mergers - phase 1 clearance with undertakings in lieu",
                "value" => "mergers-phase-1-clearance-with-undertakings-in-lieu",
              },
              {
                "label" => "Mergers - phase 1 referral",
                "value" => "mergers-phase-1-referral",
              },
              {
                "label" => "Mergers - phase 1 found not to qualify",
                "value" => "mergers-phase-1-found-not-to-qualify",
              },
              {
                "label" => "Mergers - phase 1 public interest intervention",
                "value" => "mergers-phase-1-public-interest-interventions",
              },
              {
                "label" => "Markets - phase 2 clearance - no adverse effect on competition",
                "value" => "markets-phase-2-clearance-no-adverse-effect-on-competition",
              },
              {
                "label" => "Markets - phase 2 adverse effect on competition leading to remedies",
                "value" => "markets-phase-2-adverse-effect-on-competition-leading-to-remedies",
              },
              {
                "label" => "Markets - phase 2 decision to dispense with procedural obligations",
                "value" => "markets-phase-2-decision-to-dispense-with-procedural-obligations",
              },
              {
                "label" => "Mergers - phase 2 clearance",
                "value" => "mergers-phase-2-clearance",
              },
              {
                "label" => "Mergers - phase 2 clearance with remedies",
                "value" => "mergers-phase-2-clearance-with-remedies",
              },
              {
                "label" => "Mergers - phase 2 prohibition",
                "value" => "mergers-phase-2-prohibition",
              },
              {
                "label" => "Mergers - phase 2 cancellation",
                "value" => "mergers-phase-2-cancellation",
              },
              {
                "label" => "Consumer enforcement - no formal action",
                "value" => "consumer-enforcement-no-action",
              },
              {
                "label" => "Consumer enforcement - court order",
                "value" => "consumer-enforcement-court-order",
              },
              {
                "label" => "Consumer enforcement - undertakings",
                "value" => "consumer-enforcement-undertakings",
              },
              {
                "label" => "Consumer enforcement - changes to business practices agreed",
                "value" => "consumer-enforcement-changes-to-business-practices-agreed",
              },
              {
                "label" => "Regulatory references and appeals - final determination",
                "value" => "regulatory-references-and-appeals-final-determination",
              },
            ],
            "display_as_result_metadata" => true,
            "filterable" => true,
            "key" => "outcome_type",
            "name" => "Outcome",
            "preposition" => "with outcome",
            "type" => "text",
          },
          {
            "display_as_result_metadata" => true,
            "filterable" => false,
            "key" => "opened_date",
            "name" => "Opened",
            "short_name" => "Opened",
            "type" => "date",
          },
          {
            "display_as_result_metadata" => true,
            "filterable" => true,
            "key" => "closed_date",
            "name" => "Closed",
            "preposition" => "closed",
            "short_name" => "Closed",
            "type" => "date",
          },
        ],
        "filter" => {
          "document_type" => "cma_case",
        },
        "show_summaries" => false,
      }
      finder["links"] = {
        "email_alert_signup" => [
          {
            "content_id" => "b269c38b-6e5a-4258-9735-66389749e341",
            "title" => "Competition and Markets Authority cases",
            "api_path" => "/api/content/cma-cases/email-signup",
            "base_path" => "/cma-cases/email-signup",
            "description" => "You'll get an email each time a case is updated or a new case is published.",
            "api_url" => "https://www.gov.uk/api/content/cma-cases/email-signup",
            "web_url" => "https://www.gov.uk/cma-cases/email-signup",
            "locale" => "en",
          },
        ],
        "organisations" => [
          {
            "content_id" => "271e858a-6b44-4c9c-9282-6f599d268895",
            "title" => "Competition and Markets Authority",
            "api_path" => "/api/content/government/organisations/competition-and-markets-authority",
            "base_path" => "/government/organisations/competition-and-markets-authority",
            "api_url" => "https://www.gov.uk/api/content/government/organisations/competition-and-markets-authority",
            "web_url" => "https://www.gov.uk/government/organisations/competition-and-markets-authority",
            "locale" => "en",
          },
        ],
        "related" => [],
        "available_translations" => [
          {
            "content_id" => "3631309f-b9c0-4942-afe6-3ae3819fc6a1",
            "title" => "Competition and Markets Authority cases",
            "api_path" => "/api/content/cma-cases",
            "base_path" => "/cma-cases",
            "description" => "",
            "api_url" => "https://www.gov.uk/api/content/cma-cases",
            "web_url" => "https://www.gov.uk/cma-cases",
            "locale" => "en",
          },
        ],
      }
      finder
    end
  end
end
