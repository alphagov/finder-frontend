module FacetParser
  def self.parse(facet)
    if facet.filterable
      case facet.type
      when 'text'
        SelectFacet.new(facet)
      when 'date'
        DateFacet.new(facet)
      else
        raise ArgumentError.new("Unknown filterable facet type: #{facet.type}")
      end
    else
      Facet.new(facet)
    end
  end
end
