module FinderParser
  def self.parse(content_item, finder_hash)
    Finder.new(
      name: content_item['title'],
      slug: finder_hash['slug'],
      document_noun: finder_hash['document_noun'],
      beta: content_item['details']['beta'],
      facets: FacetCollectionParser.parse(finder_hash['facets']),
      organisations: finder_hash['organisations'],
      related: finder_hash['related'],
      email_alert_signup: finder_hash['email_alert_signup'],
    )
  end
end
