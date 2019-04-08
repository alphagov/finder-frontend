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

  def facet_values(value_hash, facet)
    if facet.keys
      return facet.keys.each_with_object({}) { |key, result_hash|
        result_hash[key] = value_hash[key]
      }
    end

    value_hash[facet.key]
  end

  def filters
    facets.select(&:filterable?)
  end

  def metadata
    facets.select(&:metadata?)
  end
end
