class Facet

  delegate :key, :name, :type, :short_name, to: :facet

  def initialize(facet)
    @facet = facet
  end

  def filterable?
    facet.filterable
  end

  def metadata?
    facet.display_as_result_metadata
  end

private
  attr_reader :facet

end
