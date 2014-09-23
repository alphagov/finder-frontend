require 'gds_api/helpers'

class Finder
  include GdsApi::Helpers

  attr_reader :slug, :name, :document_noun, :facets, :related
  attr_accessor :keywords

  def self.get(slug)
    schema_attributes = FinderFrontend.get_schema(slug)
    artefact_attributes = content_api.artefact(slug)
    organisation_tags = artefact_attributes.tags.select { |t| t.details.type == "organisation" }
    related_artefacts = artefact_attributes.related

    FinderParser.parse(
      schema_attributes.send(:schema_hash).merge(
        "name" => artefact_attributes['title'],
        "organisations" => organisation_tags,
        "related"=> related_artefacts,
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

  def self.content_api
    @content_api ||= GdsApi::ContentApi.new(Plek.current.find('contentapi'))
  end
end
