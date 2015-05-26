class FilterableFacet < Facet
  attr_writer :value

  delegate :preposition, to: :facet

  def to_partial_path
    self.class.name.underscore
  end
end
