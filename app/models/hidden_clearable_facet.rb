class HiddenClearableFacet < FilterableFacet
  def initialize(facet, value_hash)
    @value = Array(value_hash)
    super(facet)
  end

  def user_visible?
    false
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

  def applied_filters
    selected_values.map do |value|
      {
        name:,
        label: value["label"],
        query_params: { key => [value["value"]] },
      }
    end
  end

  def query_params
    { key => selected_values.map { |value| value["value"] } }
  end

private

  def value_fragments
    selected_values.map do |value|
      {
        "label" => value["label"],
        "value" => value["value"],
        "parameter_key" => key,
      }
    end
  end

  def selected_values
    @selected_values ||= begin
      return [] if @value.nil?

      allowed_values.select do |option|
        @value.include?(option["value"])
      end
    end
  end
end
