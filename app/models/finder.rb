class Finder
  attr_reader :slug, :name, :document_noun, :facets

  def self.get(slug)
    FinderParser.parse(FinderFrontend.finder_api.get_schema(slug))
  end

  def initialize(attrs = {})
    @slug = attrs[:slug]
    @name = attrs[:name]
    @document_noun = attrs[:document_noun]
    @facets = attrs[:facets]
  end

  def document_noun
    "case"
  end

  def results
    @results ||= ResultSet.get(slug, facets.values)
  end
end
