class Facet
  def initialize(facet)
    @facet = facet
  end

  def key
    facet['key']
  end

  def keys
    facet['keys']
  end

  def name
    facet['name']
  end

  def type
    facet['type']
  end

  def short_name
    facet['short_name']
  end

  def filterable?
    facet['filterable']
  end

  def metadata?
    facet['display_as_result_metadata']
  end

private

  attr_reader :facet
end
