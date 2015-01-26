class FilterableFacet < Facet
  attr_reader :preposition
  attr_accessor :value

  def initialize(facet)
    super
    self.value = facet.value.presence
    @preposition = facet.preposition
  end

  def to_partial_path
    self.class.name.underscore
  end

  def selected_values
    []
  end

end
