class FacetCollection
  include Enumerable

  attr_reader :facets

  delegate :each, to: :facets

  def initialize(facets)
    @facets = facets
  end

  def values=(value_hash)
    value_hash = value_hash.stringify_keys
    filters.each do |facet|
      facet.value = value_hash[facet.key]
    end
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
