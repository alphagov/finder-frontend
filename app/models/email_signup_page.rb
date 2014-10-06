class EmailSignupPage

  def initialize(dependencies = {})
    @slug = dependencies.fetch(:slug)
    @artefact = dependencies.fetch(:artefact)
    @schema_facets = dependencies.fetch(:schema_facets)
  end

  def title
    artefact.title
  end

  def body
    artefact.details["description"]
  end

  def facets
    FacetCollectionParser.parse(emailable_facets)
  end

private

  attr_reader(
    :slug,
    :artefact,
    :schema_facets,
  )

  def document_type
    # TODO: get this from the content api respose
    SLUG_TO_DOCUMENT_TYPE_MAPPINGS.fetch(slug)
  end

  def emailable_facet_keys
    case document_type
    when "medical_safety_alert"
      %w(
        alert_type
      )
    else
      %w()
    end
  end

  def emailable_facets
    @emailable_facets ||= schema_facets.select { |facet| emailable_facet_keys.include?(facet["key"]) }
  end
end
