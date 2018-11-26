class KeywordFacet
  def initialize(keywords)
    @keywords = keywords
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      'key' => key,
      'preposition' => 'containing',
      'values' => value_fragments,
      'word_connectors' => {}
    }
  end

  def has_filters?
    keywords.present?
  end

  def key
    'keywords'
  end

  def value
    [keywords]
  end

private

  attr_reader :keywords

  def value_fragments
    [
      {
        'label' => keywords,
        'key' => key,
        'name' => 'keywords',
        'value' => keywords
      }
    ]
  end
end
