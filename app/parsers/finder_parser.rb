module FinderParser
  def self.parse(finder_hash)
    Finder.new(
      name: finder_hash['name'],
      slug: finder_hash['slug'],
      facets: FacetCollectionParser.parse(finder_hash['facets'])
    )
  end
end
