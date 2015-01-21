class Facet
  attr_reader :name, :key, :short_name, :type
  attr_accessor :value

  def initialize(facet)
    @facet = facet
    @key = facet.key
    @name = facet.name
    self.value = facet.value.presence
    @preposition = facet.preposition
    @filterable = facet.filterable.nil? ? true : facet.filterable
    @type = facet.type
    @short_name = facet.short_name
  end

  def filterable?
    false
  end

  def metadata?
    facet.metadata
  end

private
  attr_reader :facet

end
