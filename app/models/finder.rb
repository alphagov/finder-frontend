class Finder
  attr_reader :api, :name, :facets

  def self.build(args = {})
    schema = args[:api].get_schema
    facets = FacetCollection.new(facets_schema: schema['facets'],
                                 facet_values: args[:facet_values])
    new(api: args[:api], facets: facets, name: schema['name'])
  end

  def initialize(attrs = {})
    @api = attrs[:api]
    @name = attrs[:name]
    @facets = attrs[:facets]
  end
end
