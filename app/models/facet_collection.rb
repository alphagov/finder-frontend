class FacetCollection
  include Enumerable

  attr_reader :facets

  delegate :each, to: :facets

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

  def with_selected_values
    facets.select { |f| f.selected_values.present? }
  end

  def selected_facets_hash
    facets_hash = with_selected_values.map do |facet|
      {
        preposition: facet.preposition,
        key: facet.key,
        selected_values_hash: facet.selected_values_to_hash
      }
    end
    facets_hash
  end

  def to_partial_path
    'facet_collection'
  end
end
