module FinderParser
  def self.parse(finder_hash)
    Finder.new(
      name: finder_hash['name'],
      slug: finder_hash['slug'],
      document_noun: finder_hash['document_noun'],
      facets: FacetCollectionParser.parse(finder_hash['facets']),
      organisations: finder_hash['organisations'],
    )
  end
end
