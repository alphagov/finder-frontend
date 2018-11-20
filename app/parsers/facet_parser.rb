module FacetParser
  def self.parse(facet)
    if facet['filterable']
      case facet['type']
      when 'text'
        SelectFacet.new(facet)
      when 'topical'
        TopicalFacet.new(facet)
      when 'date'
        DateFacet.new(facet)
      when 'hidden'
        HiddenFacet.new(facet)
      when 'checkbox'
        CheckboxFacet.new(facet)
      else
        raise ArgumentError.new("Unknown filterable facet type: #{facet.type}")
      end
    else
      Facet.new(facet)
    end
  end
end
