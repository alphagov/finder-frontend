module FacetParser
  def self.parse(facet)
    case facet.type
    when 'multi-select'
      SelectFacet.new(facet)
    when 'date'
      DateFacet.new(facet)
    else
      raise ArgumentError.new("Unknown facet type: #{facet.type}")
    end
  end
end
