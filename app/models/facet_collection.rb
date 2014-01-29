class FacetCollection
  include Enumerable

  attr_reader :facets_schema, :facet_values

  delegate :each, to: :facets

  def initialize(attrs = {})
    @facets_schema = attrs[:facets_schema]
    @facet_values = attrs.fetch(:facet_values, {})
  end

  def facets
    @facets ||= facets_schema.map do |facet_schema_data|
      build_facet(facet_schema_data)
    end
  end

  def to_params
    facets.select { |f| f.value.present? }.each.with_object({}) do |facet, params|
      params[facet.key] = facet.value
    end
  end

  def to_partial_path
    'facet_collection'
  end

private
  def build_facet(schema)
    facet_class_for_type(schema["type"]).new(schema, facet_values[schema["key"]])
  end

  def facet_class_for_type(type)
    case type
    when "select" then SelectFacet
    else raise ArgumentError.new("Unknown facet type '#{type}'")
    end
  end
end
