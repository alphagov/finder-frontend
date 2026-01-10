require "gds_api/content_store"
require "gds_api/search"
require "gds_api/email_alert_api"

module Services
  ALLOWED_LOCAL_CONTENT = %w[
    _
    _aaib-reports
    _administrative-appeals-tribunal-decisions
    _ai-assurance-techniques
    _algorithmic-transparency-records
    _animal-disease-cases-england
    _armed-forces-covenant-businesses
    _asylum-support-tribunal-decisions
    _business-and-industry
    _business-finance-support
    _capital-grant-finder
    _childcare-parenting
    _cma-cases
    _corporate-information
    _crime-justice-and-law
    _data-access-approvals-register
    _data-ethics-guidance
    _defence-and-armed-forces
    _designs-decisions
    _drug-device-alerts
    _drug-safety-update
    _education
    _employment-appeal-tribunal-decisions
    _employment-tribunal-decisions
    _entering-staying-uk
    _environment
    _eu-withdrawal-act-2018-statutory-instruments
    _european-structural-investment-funds
    _export-health-certificates
    _find-digital-market-research
    _find-funding-for-land-or-farms
    _find-hmrc-contacts
    _find-hmrc-manuals
    _find-licences
    _flood-and-coastal-erosion-risk-management-research-reports
    _going-and-being-abroad
    _government_all
    _government_case-studies
    _government_groups
    _government_people
    _government_statistical-data-sets
    _health-and-social-care
    _housing-local-and-community
    _international-development-funding
    _international
    _life-circumstances
    _maib-reports
    _marine-equipment-approved-recommendations
    _money
    _official-documents
    _product-safety-alerts-reports-recalls
    _protected-food-drink-names
    _raib-reports
    _regional-and-local-government
    _research-for-development-outputs
    _residential-property-tribunal-decisions
    _search
    _search_all
    _search_guidance-and-regulation
    _search_news-and-communications
    _search_policy-papers-and-consultations
    _search_research-and-statistics
    _search_services
    _search_transparency-and-freedom-of-information-releases
    _service-life-saving-maritime-appliances
    _service-standard-reports
    _sfo-cases
    _society-and-culture
    _support-for-veterans
    _tax-and-chancery-tribunal-decisions
    _traffic-commissioner-regulatory-decisions
    _transport
    _welfare
    _work
    _world
    _world_organisations
  ].freeze

  # The filenames of the local files are the paths of the content items with "/" converted to "_"
  # _.json is the content item for the home page (used for taxons)
  # _search_all is the content item for /search/all, etc
  def self.filename_from_path(path)
    path_overrides = { "" => "_" }
    path_overrides[path] || path.gsub("/", "_")
  end

  def self.content_store
    GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def self.cached_content_item(base_path)
    filename = filename_from_path(base_path)

    if ALLOWED_LOCAL_CONTENT.include?(filename)
      GovukStatsd.time("file_store.fetch_request_time") do
        JSON.parse(File.read(Rails.root.join("config/local_content/#{filename}.json")))
      end
    else
      Rails.cache.fetch("finder-frontend_content_items#{base_path}", expires_in: 5.minutes) do
        GovukStatsd.time("content_store.fetch_request_time") do
          content_item = content_store.content_item(base_path)
          content_item_hash = content_item.to_h
          content_item_hash["cache_control"] = {
            "max_age" => content_item.cache_control["max-age"],
            "public" => !content_item.cache_control.private?,
          }
          content_item_hash
        end
      end
    end
  end

  def self.rummager
    GdsApi::Search.new(Plek.find("search-api"))
  end

  def self.search_api_v2
    GdsApi::SearchApiV2.new(Plek.find("search-api-v2"))
  end

  def self.email_alert_api
    Services::EmailAlertApi.new
  end

  def self.worldwide_api
    GdsApi.worldwide
  end

  def self.registries
    Registries::BaseRegistries.new
  end
end
