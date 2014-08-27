require 'gds_api/helpers'

class Finder
  include GdsApi::Helpers

  attr_reader :slug, :name, :document_noun, :facets, :related
  attr_accessor :keywords

  def self.get(slug)
    schema_attributes = FinderFrontend.finder_api.get_schema(slug).to_hash
    artefact_attributes = content_api.artefact(slug)
    organisation_tags = artefact_attributes.tags.select { |t| t.details.type == "organisation" }
    related_artefacts = artefact_attributes.related

    FinderParser.parse(
      schema_attributes.merge(
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
    @results ||= ResultSet.get(slug, search_params)
  end

  def primary_organisation
    organisations.first
  end

private
  attr_reader :organisations

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
