class FacetCollection
  include Enumerable

  attr_reader :facets

  delegate :each, to: :facets

  def initialize(facet_hashes, values)
    stringified_values_hash = values.stringify_keys
    @facets = ensure_minimum_one_open_facet(facet_hashes.map { |facet_hash|
      FacetParser.parse(facet_hash, stringified_values_hash)
    })
  end

  def to_partial_path
    'facet_collection'
  end

  def filters
    facets.select(&:filterable?)
  end

  def ensure_minimum_one_open_facet(facets_to_ensure)
    at_least_one_facet_selected = (facets_to_ensure.map { |f|
      # TODO figure out where to move this method so that it only applies to `OptionSelectFacet`. Then can remove the `defined?` check.
      (defined? f.close_facet?) ? !f.close_facet? : false
    }).any?
    unless at_least_one_facet_selected
      facets_to_ensure.first.open_facet!
    end
    facets_to_ensure
  end

  def metadata
    facets.select(&:metadata?)
  end
end
