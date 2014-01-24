class Finder
  attr_accessor :slug, :name, :facets

  def initialize(attrs = {})
    @slug = attrs[:slug]
    @name = attrs[:name]
    @facets = Array(attrs[:facets])
  end
end
