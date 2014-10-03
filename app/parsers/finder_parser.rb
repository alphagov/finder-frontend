module FinderParser
  def self.parse(finder_hash)
    Finder.new(
      name: finder_hash['name'],
      slug: finder_hash['slug'],
      document_noun: finder_hash['document_noun'],
      facets: FacetCollectionParser.parse(finder_hash['facets']),
      organisations: finder_hash['organisations'],
      related: finder_hash['related'],
      signup_page_text: finder_hash['signup_page_text'],
      signup_page_path: finder_hash['signup_page_path'],
    )
  end
end
