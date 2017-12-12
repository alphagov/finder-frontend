class FilterableFacet < Facet
  attr_accessor :value

  def preposition
    facet['preposition']
  end

  def to_partial_path
    self.class.name.underscore
  end
end
