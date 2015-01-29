class Facet
  attr_reader :name, :key, :preposition
  attr_accessor :value

  def initialize(facet)
    @key = facet.key
    @name = facet.name
    self.value = facet.value.presence
    @preposition = facet.preposition
    @filterable = facet.filterable.nil? ? true : facet.filterable
  end

  def to_partial_path
    self.class.name.underscore
  end

  def selected_values
    []
  end

  def filterable?
    @filterable
  end
end
