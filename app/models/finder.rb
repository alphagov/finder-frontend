class Finder
  attr_reader :api, :slug, :name, :facets
  attr_accessor :api

  def self.from_hash(finder_hash)
    self.new(
      name: finder_hash['name'],
      slug: finder_hash['slug'],
      facets: FacetCollection.from_hash(finder_hash.slice('facets'))
    )
  end

  def self.get(api)
    finder = self.from_hash(api.get_finder)
    finder.api = api
    finder
  end

  def self.get_with_facet_values(api, facet_values)
    finder = self.get(api)
    finder.facets.values = facet_values
    finder
  end

  def initialize(attrs = {})
    @api = attrs[:api]
    @slug = attrs[:slug]
    @name = attrs[:name]
    @facets = attrs[:facets]
  end

  def document_noun
    "case"
  end

  def results
    @results ||= ResultSet.get(api, facets.values)
  end
end
