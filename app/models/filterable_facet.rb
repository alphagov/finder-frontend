class FilterableFacet < Facet
  DEFAULT_PREPOSITION = "related to".freeze

  def preposition
    facet["preposition"] || DEFAULT_PREPOSITION
  end

  def to_partial_path
    self.class.name.underscore
  end
end
