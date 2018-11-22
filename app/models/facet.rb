class Facet
  def initialize(facet)
    @facet = facet
  end

  def key
    facet['key']
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

  def and_word_connectors
    { two_words_connector: ' and ' }
  end

  def or_word_connectors
    { words_connector: ' or ', last_word_connector: ' or ' }
  end

  def value_fragments
    raise NotImplementedError
  end

  attr_reader :facet
end
