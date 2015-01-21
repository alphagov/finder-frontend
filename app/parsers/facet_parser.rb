module FacetParser
  def self.parse(facet)
    case facet.type
    when 'multi-select', 'text'
      SelectFacet.new(facet)
    when 'date'
      DateFacet.new(facet)
    when nil
      Facet.new(facet)
    else
      raise ArgumentError.new("Unknown facet type: #{facet.type}")
    end
  end
end
