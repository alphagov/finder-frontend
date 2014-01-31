class FacetCollection
  include Enumerable

  attr_reader :facets

  delegate :each, to: :facets

  def self.from_hash(facet_collection_hash)
    self.new(
      facets: Array(facet_collection_hash['facets']).map { |facet_hash| build_facet(facet_hash) }
    )
  end

  def initialize(attrs = {})
    @facets = attrs[:facets]
  end

  def values
    facets.select { |f| f.value.present? }.each.with_object({}) do |facet, params|
      params[facet.key] = facet.value
    end
  end

  def values=(value_hash)
    value_hash = value_hash.stringify_keys
    each do |facet|
      facet.value = value_hash[facet.key]
    end
  end

  def to_partial_path
    'facet_collection'
  end

private
  def self.build_facet(facet_hash)
    facet_class_for_type(facet_hash["type"]).from_hash(facet_hash)
  end

  def self.facet_class_for_type(type)
    case type
    when "select" then SelectFacet
    else raise ArgumentError.new("Unknown facet type: #{type}")
    end
  end
end
