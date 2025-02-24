class NestedFacet < OptionSelectFacet
  attr_accessor :sub_facet_key

  def initialize(facet, values)
    @sub_facet_key = facet["sub_facet_key"]
    super
  end

  def is_main_facet?
    sub_facet_key.present?
  end
end
