class FilterableFacet < Facet
  attr_accessor :value

  delegate :preposition, to: :facet

  def initialize(facet)
    super
    self.value = facet.value.presence
  end

  def to_partial_path
    self.class.name.underscore
  end
end
