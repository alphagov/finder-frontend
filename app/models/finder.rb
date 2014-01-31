class Finder
  attr_reader :slug, :name, :facets

  def self.get(slug)
    FinderParser.parse(FinderFrontend.finder_api.get_finder(slug))
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
