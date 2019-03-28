class HiddenFacet < FilterableFacet
  attr_reader :value

  def initialize(facet, value)
    @value = value
    super(facet)
  end

  def allowed_values
    facet['allowed_values']
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      'key' => key,
      'preposition' => preposition,
      'values' => value_fragments,
      'word_connectors' => or_word_connectors
    }
  end

  def has_filters?
    value.present?
  end

private

  def value_fragments
    selected_values.map { |v|
      {
        'label' => v['label'],
        'parameter_key' => key,
      }
    }
  end

  def selected_values
    return [] if @value.nil?

    allowed_values.select { |option|
      @value.include?(option['value'])
    }
  end
end
