module FacetCollectionParser
  def self.parse(facet_hashes)
    FacetCollection.new(facets: facet_hashes.map { |facet_hash| FacetParser.parse(facet_hash) })
  end
end
