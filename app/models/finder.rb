require 'gds_api/helpers'

class Finder
  include GdsApi::Helpers

  attr_reader :slug, :name, :document_noun, :facets, :related, :email_alert_signup
  attr_accessor :keywords

  def self.get(slug)
    schema_attributes = FinderFrontend.get_schema(slug)
    content_item = content_store.content_item("/#{slug}")
    organisation_tags = content_item.links.organisations
    related_content_items = content_item.links.related
    if content_item.links.finder_email_signup
      email_alert_signup = content_item.links.finder_email_signup.first
    else
      email_alert_signup = nil
    end

    FinderParser.parse(
      schema_attributes.send(:schema_hash).merge(
        "name" => content_item['title'],
        "organisations" => organisation_tags,
        "related"=> related_content_items,
        "email_alert_signup" => email_alert_signup,
      )
    )
  end

  def initialize(attrs = {})
    @slug = attrs[:slug]
    @name = attrs[:name]
    @document_noun = attrs[:document_noun]
    @facets = attrs[:facets]
    @organisations = attrs[:organisations]
    @related = attrs[:related]
    @email_alert_signup = attrs[:email_alert_signup]
  end

  def results
    @results ||= ResultSet.get(
      slug,
      document_type,
      search_params,
    )
  end

  def primary_organisation
    organisations.first
  end

  def facet_sentence_fragments
    facets.map { |facet| facet.sentence_fragment }.compact
  end

private
  attr_reader :organisations

  def document_type
    # TODO: get this from the content api respose
    {
      "cma-cases" => "cma_case",
      "aaib-reports" => "aaib_report",
      "international-development-funding" => "international_development_fund",
      "drug-device-alerts" => "medical_safety_alert",
      "drug-safety-update" => "drug_safety_update",
    }.fetch(@slug)
  end

  def search_params
    facet_search_params.merge(keyword_search_params)
  end

  def facet_search_params
    facets.values
  end

  def keyword_search_params
    if keywords
      { "keywords" => keywords }
    else
      {}
    end
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.current.find('content-store'))
  end
end
