module FacetParser
  def self.parse(facet, value_hash)
    if facet["filterable"]
      case facet["type"]
      when "text", "content_id"
        OptionSelectFacet.new(facet, value_hash[facet["key"]])
      when "topical"
        TopicalFacet.new(facet, value_hash[facet["key"]])
      when "taxon"
        TaxonFacet.new(facet, value_hash.slice(*facet["keys"]))
      when "date"
        DateFacet.new(facet, value_hash[facet["key"]])
      when "hidden"
        HiddenFacet.new(facet, value_hash[facet["key"]])
      when "checkbox"
        CheckboxFacet.new(facet, value_hash[facet["key"]])
      when "radio"
        RadioFacet.new(facet, value_hash[facet["key"]])
      when "hidden_clearable"
        HiddenClearableFacet.new(facet, value_hash[facet["key"]])
      when "research_and_statistics"
        RadioFacetForMultipleFilters.new(facet, value_hash[facet["key"]], ::Filters::ResearchAndStatsHashes.new.call)
      when "official_documents"
        RadioFacetForMultipleFilters.new(facet, value_hash[facet["key"]], ::Filters::OfficialDocumentsHashes.new.call)
      else
        raise ArgumentError.new("Unknown filterable facet type: #{facet['type']}")
      end
    else
      Facet.new(facet)
    end
  end
end
