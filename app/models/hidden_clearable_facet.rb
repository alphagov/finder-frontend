class HiddenClearableFacet < FilterableFacet
  def initialize(facet, value_hash)
    @value = Array(value_hash)
    super(facet)
  end

  def sentence_fragment
    return nil unless selected_values.any?

    {
        "key" => key,
        "preposition" => preposition,
        "values" => value_fragments,
        "word_connectors" => or_word_connectors,
    }
  end

  def has_filters?
    selected_values.any?
  end

  def query_params
    { key => selected_values.map { |value| value["value"] } }
  end

private

  def value_fragments
    selected_values.map { |value|
      {
          "label" => value["label"],
          "value" => value["value"],
          "parameter_key" => key,
      }
    }
  end

  def selected_values
    @selected_values ||= begin
      return [] if @value.nil?

      allowed_values.select { |option|
        @value.include?(option["value"])
      }
    end
  end
end
