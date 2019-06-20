# typed: true
class FacetCollection
  include Enumerable

  attr_reader :facets

  delegate :each, to: :facets

  def initialize(facet_hashes, values)
    stringified_values_hash = values.stringify_keys
    @facets = facet_hashes.map { |facet_hash|
      FacetParser.parse(facet_hash, stringified_values_hash)
    }
  end

  def to_partial_path
    'facet_collection'
  end

  def filters
    facets.select(&:filterable?)
  end

  def metadata
    facets.select(&:metadata?)
  end
end
