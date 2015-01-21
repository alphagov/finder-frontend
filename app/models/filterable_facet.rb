class FilterableFacet < Facet
  attr_reader :preposition
  attr_accessor :value

  delegate :preposition, to: :facet

  def initialize(facet)
    super
    self.value = facet.value.presence
  end

  def to_partial_path
    self.class.name.underscore
  end

  def selected_values
    []
  end

  def filterable?
    true
  end
end
