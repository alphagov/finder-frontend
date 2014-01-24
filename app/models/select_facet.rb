class SelectFacet < Facet
  attr_accessor :options

  def initialize(attrs = {})
    super
    @options = attrs[:options]
  end
end
