class HiddenFacet < FilterableFacet
  def initialize(facet, value)
    @value = Array(value)
    super(facet)
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      "key" => key,
      "preposition" => preposition,
      "values" => value_fragments,
      "word_connectors" => or_word_connectors,
    }
  end

  def has_filters?
    @value.present?
  end

  def query_params
    values = allowed_values.empty? ? @value : selected_values.map { |value| value["value"] }
    { key => values }
  end

private

  def value_fragments
    selected_values.map { |value|
      {
          "label" => value["label"],
          "parameter_key" => key,
      }
    }
  end

  def selected_values
    return [] if @value.nil?

    allowed_values.select { |option|
      @value.include?(option["value"])
    }
  end
end
