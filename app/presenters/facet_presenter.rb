class FacetPresenter < SimpleDelegator
  attr_reader :section_index, :section_count

  def initialize(facet, section_index, section_count)
    super(facet)

    # Facet index is 1-based for GOV.UK analytics
    @section_index = section_index + 1 if section_index
    @section_count = section_count
  end
end
