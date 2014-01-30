class Finder
  attr_reader :slug, :name, :facets

  def self.from_hash(finder_hash)
    self.new(
      name: finder_hash['name'],
      slug: finder_hash['slug'],
      facets: FacetCollection.from_hash(finder_hash.slice('facets'))
    )
  end

  def self.get(slug)
    finder = self.from_hash(FinderFrontend.finder_api.get_finder(slug))
    finder
  end

  def self.get_with_facet_values(slug, facet_values)
    finder = self.get(slug)
    finder.facets.values = facet_values
    finder
  end

  def initialize(attrs = {})
    @slug = attrs[:slug]
    @name = attrs[:name]
    @facets = attrs[:facets]
  end

  def document_noun
    "case"
  end

  def results
    @results ||= ResultSet.get(slug, facets.values)
  end
end
