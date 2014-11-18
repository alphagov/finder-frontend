class FacetCollection
  include Enumerable

  attr_reader :facets

  def initialize(facets)
    @facets = facets
  end

  def values
    facets.select { |f| f.value.present? }.each.with_object({}) do |facet, params|
      params[facet.key] = facet.value
    end
  end

  def values=(value_hash)
    value_hash = value_hash.stringify_keys
    facets.each do |facet|
      facet.value = value_hash[facet.key]
    end
  end

  def with_selected_values
    facets.select { |f| f.selected_values.present? }
  end

  def to_partial_path
    'facet_collection'
  end

  def to_a
    facets
  end
end
