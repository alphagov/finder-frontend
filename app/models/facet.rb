class Facet

  delegate :key, :name, :type, :short_name, to: :facet

  def initialize(facet)
    @facet = facet
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
