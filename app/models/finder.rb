class Finder
  attr_reader :slug, :name, :document_noun, :facets
  attr_accessor :keywords

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
    @results ||= ResultSet.get(slug, search_params)
  end

  private

  def search_params
    facet_search_params.merge(keyword_search_params)
  end

  def facet_search_params
    facets.values
  end

  def keyword_search_params
    if keywords
      { "keywords" => keywords }
    else
      {}
    end
  end
end
